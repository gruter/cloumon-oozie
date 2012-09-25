package org.cloumon.gruter.oozie.service;

import java.io.BufferedWriter;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import javax.annotation.Resource;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.hive.conf.HiveConf;
import org.apache.hadoop.io.Writable;
import org.apache.hadoop.mapred.InputFormat;
import org.apache.hadoop.mapred.JobConf;
import org.apache.hadoop.mapred.Mapper;
import org.apache.hadoop.mapred.OutputFormat;
import org.apache.hadoop.mapred.Reducer;
import org.apache.oozie.DagEngine;
import org.apache.oozie.DagEngineException;
import org.apache.oozie.ErrorCode;
import org.apache.oozie.WorkflowJobBean;
import org.apache.oozie.WorkflowsInfo;
import org.apache.oozie.client.OozieClient;
import org.apache.oozie.client.WorkflowAction;
import org.apache.oozie.service.DagEngineService;
import org.apache.oozie.service.Services;
import org.apache.oozie.servlet.XServletException;
import org.apache.oozie.util.JobUtils;
import org.apache.oozie.util.XConfiguration;
import org.cloumon.gruter.oozie.dao.IWorkflowDAO;
import org.cloumon.gruter.oozie.dao.WorkflowDAO;
import org.cloumon.gruter.oozie.model.AppLibFile;
import org.cloumon.gruter.oozie.model.OozieApp;
import org.cloumon.gruter.oozie.model.OozieClusterInfo;
import org.cloumon.gruter.oozie.model.OozieHiveQuery;
import org.cloumon.gruter.oozie.model.OozieJob;
import org.cloumon.gruter.oozie.model.OozieJobAction;
import org.cloumon.gruter.oozie.model.OozieJobHistory;
import org.cloumon.gruter.oozie.model.OozieJobStatus;
import org.cloumon.gruter.oozie.service.external.HadoopCluster;
import org.cloumon.gruter.oozie.service.external.HiveConnection;
import org.cloumon.gruter.oozie.service.external.HiveQuery;
import org.cloumon.gruter.oozie.service.external.IAlarmService;
import org.cloumon.gruter.oozie.service.external.IConfService;
import org.cloumon.gruter.oozie.service.external.IHadoopService;
import org.cloumon.gruter.oozie.service.external.IHiveMetaStoreService;
import org.cloumon.gruter.oozie.service.external.IHiveQueryService;
import org.cloumon.gruter.oozie.service.external.IMapReduceService;
import org.cloumon.gruter.oozie.service.external.OozieExternalService;
import org.cloumon.gruter.oozie.service.timer.JobRunner;
import org.cloumon.gruter.oozie.service.timer.JobTimer;
import org.cloumon.gruter.oozie.service.timer.ScheduledJob;
import org.cloumon.gruter.oozie.web.CloumonOozieServicesLoader;
import org.codehaus.jackson.map.DeserializationConfig;
import org.codehaus.jackson.map.ObjectMapper;
import org.springframework.stereotype.Service;

@Service("workflowService")
public class WorkflowService implements IWorkflowService, JobRunner {
	//TOOD Job이 실행된 후 luanch job에서 에러가 발생한 경우 결과 처리(job counter의 oozie.launcher	oozie.launcher.error = 1)
	public static final Log LOG = LogFactory.getLog(WorkflowService.class);
	
	public static final String APP_XML_FILE = "workflow.xml";
	
	public static final String APP_DATA_FILE = "cloumon.dat";
	
//	public static final String OOZIE_COMMON_LIB = "common_lib";
	
	private static Pattern varPat = Pattern.compile("\\$\\{[^\\}\\$\u0020]+\\}");

	public static ObjectMapper om = new ObjectMapper();
	static {
		om.getDeserializationConfig().disable(DeserializationConfig.Feature.FAIL_ON_UNKNOWN_PROPERTIES);
	}

	@Resource(type = WorkflowDAO.class)
	IWorkflowDAO workflowDAO;

	@Resource(type=OozieExternalService.class)
	IHadoopService hadoopService;
	
	@Resource(type=OozieExternalService.class)
	IMapReduceService mapReduceService;
	
	@Resource(type=OozieExternalService.class)
	IHiveMetaStoreService hiveMetaStoreService;
	
	@Resource(type=OozieExternalService.class)
	IHiveQueryService hiveQueryService;
	
	private Configuration hdfsConf;

	@Resource(type = OozieExternalService.class)
	private IConfService confService;

	private JobTimer jobTimer;
	
	private Map<String, JobStatusChecker> jobStatusCheckers = new HashMap<String, JobStatusChecker>();
	
	@Resource(type=OozieExternalService.class)
	IAlarmService alarmService;
	
	public WorkflowService() throws Exception {
	}
	
	@PostConstruct
	public void init() {
		hdfsConf = new Configuration();

//		final Properties props = new Properties();
//		try {
//			props.load(this.getClass().getResourceAsStream("/settings.properties"));
//		} catch (IOException e) {
//			LOG.error(e.getMessage(), e);
//		}
		File userDir = new File(System.getProperty("user.dir"));
		//String oozieHome = props.get("oozieHome") != null ? props.get("oozieHome").toString() : (System.getProperty("user.dir"));
		System.setProperty("oozie.home.dir", userDir.getAbsolutePath());
		System.setProperty("oozie.data.dir", userDir.getAbsolutePath() + "/oozieData");

		Thread t = new Thread() {
			public void run() {
				while(true) {
					if(Services.get() == null) {
						try {
							Thread.sleep(10 * 1000);
						} catch (InterruptedException e) {
						}
					} else {
						uploadPigLib();
						uploadHiveLib();
						break;
					}
				}
			}
		};
		t.start();
		
		boolean oozieDisable = confService.getBoolean("cloumon.service.oozie.disable", false);
		if(!oozieDisable) {
			jobTimer = new JobTimer(this);
			jobTimer.start();
		}		
	}

	private void uploadPigLib() {
		if(Services.get() == null) {
			return;
		}
		Path appRootPath = new Path(confService.get("cloumon.oozie.appRootPath", "hdfs://127.0.0.1:9000/tmp/oozie/app"));
		String oozieCommonLibPath = Services.get().getConf().get("oozie.service.WorkflowAppService.system.libpath");
		if(oozieCommonLibPath == null) {
			oozieCommonLibPath = appRootPath.getParent().toString() + "/common_lib";
		}
		Path commonLibPath = new Path(oozieCommonLibPath);
		
		String pigHome = confService.get("cloumon-oozie.pig.home.path");
		if(pigHome == null) {
			LOG.warn("No pigHome property in setting.properties. you need upload pig library files to " + commonLibPath + "/pig");
			return;
		}
		File pigHomeDir = new File(pigHome);
		if(!pigHomeDir.exists()) {
			LOG.warn("Not exists " + pigHome + ". you need upload pig library files to " + commonLibPath + "/pig");
			return;
		}
		try {
			FileSystem fs = appRootPath.getFileSystem(hdfsConf);
			Path pigHomePath = new Path(commonLibPath, "pig");
			if(!fs.exists(pigHomePath)) {
				fs.mkdirs(pigHomePath);
			}
			File[] libFiles = pigHomeDir.listFiles();
			for(File eachFile: libFiles) {
				if(eachFile.getName().endsWith("withouthadoop.jar")) {
					if(!fs.exists(new Path(pigHomePath, eachFile.getName()))) {
						fs.copyFromLocalFile(new Path("file://" + eachFile.getAbsolutePath()), pigHomePath);
					}
				}
			}
		} catch (IOException e) {
			LOG.error(e.getMessage(), e);
		}	
	}
	
	private void uploadHiveLib() {
		if(Services.get() == null) {
			return;
		}
		Path appRootPath = new Path(confService.get("cloumon.oozie.appRootPath", "hdfs://127.0.0.1:9000/tmp/oozie/app"));
		String oozieCommonLibPath = Services.get().getConf().get("oozie.service.WorkflowAppService.system.libpath");
		if(oozieCommonLibPath == null) {
			oozieCommonLibPath = appRootPath.getParent().toString() + "/common_lib";
		}
		Path commonLibPath = new Path(oozieCommonLibPath);

		String hiveHome = confService.get("cloumon-oozie.hive.home.path");
		if(hiveHome == null) {
			LOG.warn("No hiveHome property in setting.properties. you need upload hive-default.xml, hive-site.xml, hive library files to " + commonLibPath + "/hive");
			return;
		}
		File hiveHomeDir = new File(hiveHome);
		if(!hiveHomeDir.exists()) {
			LOG.warn("Not exists " + hiveHome + ". you need upload hive-default.xml, hive-site.xml, hive library files to " + commonLibPath + "/hive");
			return;
		}
		try {
			FileSystem fs = appRootPath.getFileSystem(hdfsConf);
			Path hiveHomePath = new Path(commonLibPath, "hive");
			if(!fs.exists(hiveHomePath)) {
				fs.mkdirs(hiveHomePath);
			}
			File defaultConfFile = new File(hiveHome + "/conf/hive-default.xml");
			if(!defaultConfFile.exists()) {
				defaultConfFile = new File(hiveHome + "/conf/hive-default.xml.template");
			}
			if(defaultConfFile.exists() && !fs.exists(new Path(hiveHomePath, "hive-default.xml"))) {
				fs.copyFromLocalFile(new Path("file://" + defaultConfFile.getAbsolutePath()), new Path(hiveHomePath, "hive-default.xml"));
			}
			
			File siteXmlFile = new File(hiveHome + "/conf/hive-site.xml");
			if(siteXmlFile.exists() && !fs.exists(new Path(hiveHomePath, "hive-site.xml"))) {
				fs.copyFromLocalFile(new Path("file://" + siteXmlFile.getAbsolutePath()), new Path(hiveHomePath, "hive-site.xml"));
			}
			
			File[] libFiles = (new File(hiveHomeDir, "lib")).listFiles();
			for(File eachFile: libFiles) {
				if(eachFile.getName().endsWith(".jar")) {
					if(!fs.exists(new Path(hiveHomePath, eachFile.getName()))) {
						fs.copyFromLocalFile(new Path("file://" + eachFile.getAbsolutePath()), hiveHomePath);
					}
				}
			}
			//Path hiveLibPath = new Path(hiveHomePath, "lib");
			//if(!fs.exists(hiveLibPath)) {
				//fs.copyFromLocalFile(new Path("file://" + hiveHomeDir + "/lib"), hiveHomePath);
			//}
		} catch (IOException e) {
			LOG.error(e.getMessage(), e);
		}
	}
	
	@PreDestroy 
	public void close() {
		if(jobTimer != null) {
			jobTimer.callStop();
		}
		if(jobStatusCheckers != null) {
			synchronized(jobStatusCheckers) {
				for(JobStatusChecker eachChecker: jobStatusCheckers.values()) {
					eachChecker.interrupt();
				}
			}
		}
		
		Services service = Services.get();
		if(service != null && service.get(DagEngineService.class) != null) {
			service.get(DagEngineService.class).destroy();
		}
	}
	
	@Override
	public List<String> getCommonFiles(String type) throws Exception {
		Path appRootPath = new Path(confService.get("cloumon.oozie.appRootPath", "hdfs://127.0.0.1:9000/tmp/oozie/app"));
		String oozieCommonLibPath = Services.get().getConf().get("oozie.service.WorkflowAppService.system.libpath");
		if(oozieCommonLibPath == null) {
			oozieCommonLibPath = appRootPath.getParent().toString() + "/common_lib";
		}
		Path commonLibPath = new Path(oozieCommonLibPath);
		Path typePath = new Path(commonLibPath, type);
		
		FileSystem fs = typePath.getFileSystem(hdfsConf);
		if(!fs.exists(typePath)) {
			return new ArrayList<String>();
		}
		
		Set<String> result = new HashSet<String>();
		
		FileStatus[] files = fs.listStatus(typePath);
		if(files != null) {
			for(FileStatus eachFile: files) {
				if(eachFile.isDir()) {
					listFiles(fs, eachFile.getPath(), result);
				} else {
					result.add(eachFile.getPath().toString());
				}
			}
		}
		
		return new ArrayList<String>(result);
	}
	
	private void listFiles(FileSystem fs, Path path, Set<String> result) throws Exception {
		FileStatus[] files = fs.listStatus(path);
		if(files != null) {
			for(FileStatus eachFile: files) {
				if(eachFile.isDir()) {
					listFiles(fs, eachFile.getPath(), result);
				} else {
					result.add(eachFile.getPath().toString());
				}
			}
		}
	}

	@Override
	public void callback(String jobId, String actionId, String status) throws Exception {
    DagEngine dagEngine = Services.get().get(DagEngineService.class).getSystemDagEngine();
    try {
        dagEngine.processCallback(actionId, status, null);
    }
    catch (DagEngineException ex) {
    	LOG.error(ex.getMessage(), ex);
      throw new XServletException(HttpServletResponse.SC_BAD_REQUEST, ex);
    }  	
	}

	@Override
	public void saveApp(OozieApp oozieApp) throws Exception {
//		workflowDAO.insertOozieApp(oozieApp);
		Path appRootPath = new Path(confService.get("cloumon.oozie.appRootPath", "hdfs://127.0.0.1:9000/tmp/oozie/app"));
		FileSystem fs = appRootPath.getFileSystem(hdfsConf);

		Path appPath = new Path(appRootPath, oozieApp.getAppName());

		fs.mkdirs(appPath);
		
		Path appInfoFile = new Path(appPath, APP_DATA_FILE);
		Path appXmlFile = new Path(appPath, APP_XML_FILE);
		try {
			OutputStream out = fs.create(appInfoFile);
			
			try {
				out.write(om.writeValueAsString(oozieApp).getBytes());
			} finally {
				out.close();
			}
			
			out = fs.create(appXmlFile);
			
			try {
				out.write(oozieApp.getXml().getBytes());
			} finally {
				out.close();
			}
		} catch (Exception e) {
			if(fs.exists(appInfoFile)) {
				fs.delete(appInfoFile, false);
			}
			if(fs.exists(appXmlFile)) {
				fs.delete(appXmlFile, false);
			}

			throw e;
		}
	}

	@Override
	public List<OozieApp> listOozieApp() throws Exception {
//		return workflowDAO.selectOozieApp();
		Path appRootPath = new Path(confService.get("cloumon.oozie.appRootPath", "hdfs://127.0.0.1:9000/tmp/oozie/app"));
		FileSystem fs = appRootPath.getFileSystem(hdfsConf);
		
		FileStatus[] appDirs = fs.listStatus(appRootPath);
		
		List<OozieApp> appList = new ArrayList<OozieApp>();
		
		for(FileStatus eachFile: appDirs) {
			if(!eachFile.isDir()) {
				continue;
			}
			try {
				OozieApp app = getOozieApp(fs, eachFile.getPath());
				
				if(app == null) {
					continue;
				}
				appList.add(app);
			} catch (Exception e) {
				LOG.error(e.getMessage());
			}
		}
		
		return appList;
	}
	
	private OozieApp getOozieApp(FileSystem fs, Path appPath) throws Exception {
		Path dataPath = new Path(appPath, APP_DATA_FILE);
		OozieApp app = null;
		if(fs.exists(dataPath)) {
			InputStream in = fs.open(dataPath);
			try {
				app = om.readValue(in, OozieApp.class);
			} finally {
				in.close();
			}
		} else {
			app = new OozieApp();
			app.setAppName(appPath.getName());
		}
		
		Path xmlPath = new Path(appPath, APP_XML_FILE);
		if(fs.exists(xmlPath)) {
			app.setXml(readFull(fs, xmlPath));
		}
		return app;
	}
	
	private String readFull(FileSystem fs, Path path) throws Exception {
		StringBuilder sb = new StringBuilder();
		
		InputStream in = fs.open(path);
		try {
			byte[] buf = new byte[1024 * 1024];
			int readBytes = 0;
			while((readBytes = in.read(buf)) > 0) {
				sb.append(new String(buf, 0, readBytes));
			}
		} finally {
			in.close();
		}
		
		return sb.toString();
	}

	@Override
	public void deleteOozieApp(String appName) throws Exception {
//		workflowDAO.deleteOozieApp(appName);
	
		Path appRootPath = new Path(confService.get("cloumon.oozie.appRootPath", "hdfs://127.0.0.1:9000/tmp/oozie/app"));
		FileSystem fs = appRootPath.getFileSystem(hdfsConf);

		Path appPath = new Path(appRootPath, appName);
		
		//Path appInfoFile = new Path(appPath, APP_DATA_FILE);

		//TODO delete app dir
		fs.delete(appPath, true);
	}
	

	@Override
	public OozieApp getOozieApp(String appName) throws Exception {
		Path appRootPath = new Path(confService.get("cloumon.oozie.appRootPath", "hdfs://127.0.0.1:9000/tmp/oozie/app"));
		
		FileSystem fs = appRootPath.getFileSystem(hdfsConf);

		Path appPath = new Path(appRootPath, appName);

		OozieApp oozieApp = getOozieApp(fs, appPath);
		
		oozieApp.parseXml();
		
		return oozieApp;
	}

	@Override
	public List<String> findProperties(String xml, boolean includeFuncion) throws Exception {
		List<String> result = new ArrayList<String>();
		if (xml == null || xml.isEmpty()) {
			return result;
		}

		Set<String> variables = new TreeSet<String>();
		Matcher matcher = varPat.matcher(xml);
		while (matcher.find()) {
			String variable = xml.substring(matcher.start(), matcher.end());
			if (!includeFuncion && variable.startsWith("${wf:")) {
				continue;
			}
			variables.add(variable.substring(2, variable.length() - 1));
		}

		result.addAll(variables);

		return result;
	}

	@Override
	public void saveJob(OozieJob job) throws Exception {
		OozieJob selectedJob = this.getOozieJob(job.getJobName());
		if(selectedJob == null) {
			this.insertJob(job);
		} else {
			this.updateJob(job);
		}
	}
	
	@Override
	public void insertJob(OozieJob oozieJob) throws Exception {
		OozieApp app = this.getOozieApp(oozieJob.getAppName());
		if (app == null) {
			throw new IOException("No app:" + oozieJob.getAppName());
		}
		oozieJob.setXml(app.getXml());
		workflowDAO.insertOozieJob(oozieJob);
	}

	@Override
	public void updateJob(OozieJob oozieJob) throws Exception {
		OozieApp app = this.getOozieApp(oozieJob.getAppName());
		if (app == null) {
			throw new IOException("No app:" + oozieJob.getAppName());
		}
		oozieJob.setXml(app.getXml());
		workflowDAO.updateOozieJob(oozieJob);
	}

	@Override
	public List<OozieJob> listOozieJob() throws Exception {
		return workflowDAO.selectOozieJob(null);
	}

	@Override
	public void deleteOozieJob(String jobName) throws Exception {
		workflowDAO.deleteOozieJob(jobName);
		workflowDAO.deleteOozieJobHistory(jobName);
	}

	@Override
	public List<OozieJob> listOozieJobByApp(String appName) throws Exception {
		if (appName == null || appName.isEmpty()) {
			return new ArrayList<OozieJob>();
		}
		return workflowDAO.selectOozieJobByApp(appName);
	}

	@Override
	public List<OozieJobStatus> getJobHistory(String jobName, String from, String to) throws Exception {
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		Timestamp fromTime = null;
		Timestamp toTime = null;
		if(from != null && !from.trim().isEmpty()) {
			fromTime = new Timestamp(df.parse(from + " 00:00:00").getTime());
			if(to == null || to.trim().isEmpty()) {
				toTime = new Timestamp(System.currentTimeMillis());
			} else {
				toTime = new Timestamp(df.parse(to + " 23:59:59").getTime());
			}
		}
		
		String filter = null;
		String startStr = null;
		String lenStr = null;
		int start = (startStr != null) ? Integer.parseInt(startStr) : 1;
		start = (start < 1) ? 1 : start;
		int len = (lenStr != null) ? Integer.parseInt(lenStr) : 50;
		len = (len < 1) ? 50 : len;
		
		String oozieUser = confService.get("cloumon.service.oozie.defaultUser", "hadoop");
		DagEngine dagEngine = Services.get().get(DagEngineService.class).getDagEngine(oozieUser, "?");
		WorkflowsInfo jobs = dagEngine.getJobs(filter, start, len);
		List<WorkflowJobBean> workflowJobs = jobs.getWorkflows();

		List<OozieJobStatus> jobHistoryList = new ArrayList<OozieJobStatus>();

		Set<String> jobIds = new HashSet<String>();
		if(jobName != null && !jobName.trim().isEmpty()) {
			List<OozieJobHistory> jobHistories = workflowDAO.selectOozieJobHistory(jobName, fromTime, toTime);
			if(jobHistories == null) {
				return jobHistoryList;
			}
			
			for(OozieJobHistory eachHistory: jobHistories) {
				jobIds.add(eachHistory.getJobId());
			}
		}
		
		for(WorkflowJobBean eachJob: workflowJobs) {
			if(jobName != null && !jobName.trim().isEmpty()) {
				if(!jobIds.contains(eachJob.getId())) {
					continue;
				}
			}
			if(fromTime != null) {
				if(eachJob.getCreatedTime() != null && eachJob.getCreatedTime().getTime() >= fromTime.getTime() && eachJob.getCreatedTime().getTime() <= toTime.getTime()) {
					jobHistoryList.add(new OozieJobStatus(eachJob));
				}
			} else {
				jobHistoryList.add(new OozieJobStatus(eachJob));
			}
		}
		return jobHistoryList;
	}

	@Override
	public OozieJob getOozieJob(String jobName) throws Exception {
		List<OozieJob> result = workflowDAO.selectOozieJob(jobName);
		if (result == null || result.isEmpty()) {
			return null;
		}

		OozieJob job = result.get(0);
		
		OozieApp app = this.getOozieApp(job.getAppName());
		if(app == null) {
			throw new IOException("No oozie app info:" + job.getAppName());
		}
		
		job.setXml(app.getXml());
		return job;
	}

	@Override
	public void killJob(String jobId) throws Exception {
		String oozieUser = confService.get("cloumon.service.oozie.defaultUser", "hadoop");
		DagEngine dagEngine = Services.get().get(DagEngineService.class).getDagEngine(oozieUser, "?");
		dagEngine.kill(jobId);
	}

	@Override
	public void suspendJob(String jobId) throws Exception {
		String oozieUser = confService.get("cloumon.service.oozie.defaultUser", "hadoop");
		DagEngine dagEngine = Services.get().get(DagEngineService.class).getDagEngine(oozieUser, "?");
		dagEngine.suspend(jobId);
	}

	@Override
	public void resumeJob(String jobId) throws Exception {
		String oozieUser = confService.get("cloumon.service.oozie.defaultUser", "hadoop");
		DagEngine dagEngine = Services.get().get(DagEngineService.class).getDagEngine(oozieUser, "?");
		dagEngine.resume(jobId);
	}
	
	@Override
	public String runApp(String appName, String userName, String mailTo, HashMap<String, String> params) throws Exception {
		OozieJob job = new OozieJob();
		job.setAppName(appName);
		job.setJobName(appName + "_" + System.currentTimeMillis());
		Path appRootPath = new Path(confService.get("cloumon.oozie.appRootPath", "hdfs://127.0.0.1:9000/tmp/oozie/app"));
		Path appPath = new Path(appRootPath, job.getAppName());
		XConfiguration conf = new XConfiguration();

		//String oozieUser = confService.get("cloumon.service.oozie.defaultUser", "hadoop");
		conf.set(OozieClient.USER_NAME, userName);
		conf.set(OozieClient.APP_PATH, appPath.toString());
		
		for (Map.Entry<String, String> entry : params.entrySet()) {
			conf.set(entry.getKey(), entry.getValue());
		}
		String jobId = runOozieJob(job, conf);
		
		long execTime = System.currentTimeMillis();
		OozieJobHistory history = new OozieJobHistory();
		history.setJobName(job.getJobName());
		history.setJobId(jobId);
		history.setExecTime(new Timestamp(execTime));
		workflowDAO.insertOozieJobHistory(history);
		
		synchronized(jobStatusCheckers) {
			JobStatusChecker checker = new JobStatusChecker(jobId, job.getJobName(), mailTo);
			checker.start();
			jobStatusCheckers.put(jobId, checker);
		}
		return jobId;		
	}
	
	@Override
	public String runJob(String jobName) throws Exception {
		OozieJob job = getOozieJob(jobName);
		if (job == null) {
			throw new IOException("No job info:" + jobName);
		}
		Path appRootPath = new Path(confService.get("cloumon.oozie.appRootPath", "hdfs://127.0.0.1:9000/tmp/oozie/app"));
		Path appPath = new Path(appRootPath, job.getAppName());
		XConfiguration conf = new XConfiguration();

		//String oozieUser = confService.get("cloumon.service.oozie.defaultUser", "hadoop");
		conf.set(OozieClient.USER_NAME, job.getUserName());
		conf.set(OozieClient.APP_PATH, appPath.toString());
		
		for (Map.Entry<String, String> entry : job.getJobParamMap().entrySet()) {
			conf.set(entry.getKey(), entry.getValue());
		}
		String jobId = runOozieJob(job, conf);
		
		long execTime = System.currentTimeMillis();
		OozieJobHistory history = new OozieJobHistory();
		history.setJobName(jobName);
		history.setJobId(jobId);
		history.setExecTime(new Timestamp(execTime));
		workflowDAO.insertOozieJobHistory(history);
		
		OozieJob oozieJob = this.getOozieJob(jobName);
		oozieJob.setLastJobId(jobId);
		oozieJob.setLastExecutionTime(new Timestamp(execTime));
		workflowDAO.updateOozieJob(oozieJob);
		
		synchronized(jobStatusCheckers) {
			JobStatusChecker checker = new JobStatusChecker(jobId, jobName);
			checker.start();
			jobStatusCheckers.put(jobId, checker);
		}
		return jobId;
	}

	public String runOozieJob(OozieJob job, XConfiguration conf) throws Exception {
		OozieJobUtil oozieJobUtil = new OozieJobUtil(CloumonOozieServicesLoader.services);

		conf = conf.trim();
		conf = conf.resolve();
		validateJobConfiguration(conf);
		
		JobUtils.normalizeAppPath(conf.get(OozieClient.USER_NAME), conf.get(OozieClient.GROUP_NAME), conf);

		String appPath = conf.get(OozieClient.APP_PATH);

		if (appPath == null || appPath.isEmpty()) {
			throw new IOException("No app path i job property:" + job.getJobName());
		}
		LOG.info("App path:" + appPath);
//		if (job != null) {
//			Path appFilePath = new Path(appPath, "workflow.xml");
//			FileSystem fs = appFilePath.getFileSystem(hdfsConf);
//			OutputStream out = null;
//			try {
//				out = fs.create(appFilePath, true);
//				out.write(job.getXml().getBytes());
//			} finally {
//				if (out != null) {
//					out.close();
//				}
//			}
//		}
		String jobId = oozieJobUtil.submitJob(conf);
		LOG.info("===> Run job: JobId=" + jobId);

		return jobId;
	}

	@Override
	public OozieJobStatus getOozieJobStatus(String jobId) throws Exception {
		String oozieUser = confService.get("cloumon.service.oozie.defaultUser", "hadoop");
		DagEngine dagEngine = Services.get().get(DagEngineService.class).getDagEngine(oozieUser, "?");
		WorkflowJobBean jobBean = (WorkflowJobBean) dagEngine.getJob(jobId, 1, Integer.MAX_VALUE);
		
		OozieJobStatus jobStatus = new OozieJobStatus(jobBean);
		List<WorkflowAction> actions = jobBean.getActions();
		List<OozieJobAction> jobActions = new ArrayList<OozieJobAction>();
		if(actions != null) {
			for(WorkflowAction eachAction: actions) {
				jobActions.add(new OozieJobAction(eachAction));
			}
		}
		jobStatus.setActions(jobActions);
		
		jobStatus.setXml(dagEngine.getDefinition(jobId));
		
		return jobStatus;
	}

	@Override
	public String getJobLog(String jobId) throws Exception {
		String oozieUser = confService.get("cloumon.service.oozie.defaultUser", "hadoop");
		DagEngine dagEngine = Services.get().get(DagEngineService.class).getDagEngine(oozieUser, "?");
		
		//TODO 임시 파일로 write하고 tail해서 반환하도록 수정
		ByteArrayOutputStream bout = new ByteArrayOutputStream();

		BufferedWriter bwriter = new BufferedWriter(new OutputStreamWriter(bout));

		dagEngine.streamLog(jobId, bwriter);
		
		return new String(bout.toByteArray());
	}
	
	@Override
	public String saveQuery(String appName, String queryFile, String query) throws Exception {
		String appRootPath = confService.get("cloumon.oozie.appRootPath", "hdfs://127.0.0.1:9000/tmp/oozie/app");
		Path path = new Path(appRootPath);
		
		Path filePath = new Path(path, appName + "/" + queryFile);
	
		FileSystem fs = filePath.getFileSystem(hdfsConf);
		OutputStream out = fs.create(filePath);
		
		try {
			out.write(query.getBytes("UTF-8"));
		} finally {
			out.close();
		}
		
		return filePath.toString();
	}
	
	@Override
	public String getQuery(String appName, String queryFile) throws Exception {
		String appRootPath = confService.get("cloumon.oozie.appRootPath", "hdfs://127.0.0.1:9000/tmp/oozie/app");
		Path path = new Path(appRootPath);
		
		Path filePath = new Path(path, appName + "/" + queryFile);
	
		FileSystem fs = filePath.getFileSystem(hdfsConf);
		return readFull(fs, filePath);
	}
	
	@Override
	public void removeAppLibFile(String appName, String fileName, String libPath) throws Exception {
		String appRootPath = confService.get("cloumon.oozie.appRootPath", "hdfs://127.0.0.1:9000/tmp/oozie/app");
		Path path = new Path(appRootPath);
		
		Path filePath = null;
		if(libPath == null || libPath == "") {
			filePath = new Path(path, appName + "/" + fileName);
		} else {
			filePath = new Path(path, appName + "/lib/" + fileName);
		}
		
		FileSystem fs = path.getFileSystem(hdfsConf);
		
		LOG.info("Remove App lib file:" + filePath);
		if(fs.exists(filePath)) {
			fs.delete(filePath);
		}
	}
	
	@Override
	public List<AppLibFile> getAppLibFiles(String appName) throws Exception {
		String appRootPath = confService.get("cloumon.oozie.appRootPath", "hdfs://127.0.0.1:9000/tmp/oozie/app");
		
		Path path = new Path(appRootPath + "/" + appName);
		
		List<AppLibFile> files = new ArrayList<AppLibFile>();
		
		FileSystem fs = path.getFileSystem(hdfsConf);
		
		if(!fs.exists(path)) {
			return files;
		}
		
		FileStatus[] appFiles = fs.listStatus(path);
		if(appFiles == null) {
			return files;
		}
		
		for(FileStatus eachFile: appFiles) {
			if(!eachFile.isDir()) {
				files.add(makeAppLibFile(eachFile));
			} else {
				if("lib".equals(eachFile.getPath().getName())) {
					FileStatus[] libFiles = fs.listStatus(eachFile.getPath());
					if(libFiles == null) {
						continue;
					}
					
					for(FileStatus eachLibFile: libFiles) {
						if(!eachLibFile.isDir()) {
							files.add(makeAppLibFile(eachLibFile));
						}
					}
				}
			}
			
		}
		
		return files;
	}
	
	@Override
	public AppLibFile getAppLibFile(String fullPath) throws Exception {
		Path path = new Path(fullPath);
		
		FileSystem fs = path.getFileSystem(hdfsConf);
		
		FileStatus fileStatus = fs.getFileStatus(path);
		if(fileStatus == null) {
			throw new IOException("Not exists:" + fullPath);
		}
		
		AppLibFile item = makeAppLibFile(fileStatus);
		
		item.setClassList(JarUtil.findClass(hdfsConf, fileStatus.getPath(), 
				new Class[]{ Mapper.class, Reducer.class, Writable.class, InputFormat.class, OutputFormat.class}));

		return item;
	}

	private AppLibFile makeAppLibFile(FileStatus fileStatus) throws Exception {
		AppLibFile file = new AppLibFile();
		
		file.setFileName(fileStatus.getPath().getName());
		file.setFullPath(fileStatus.getPath().toString());
		file.setAppName(fileStatus.getPath().getParent().getParent().getName());
		file.setLength(fileStatus.getLen());
		file.setLastModifiedTime(fileStatus.getModificationTime());

		if("lib".equals(fileStatus.getPath().getParent().getName())) {
			file.setLibPath("lib");
		} else {
			file.setLibPath("");
		}
		return file;
	}
	
	public Map<String, String> getDefaultJobProperties(String type) throws Exception {
		Map<String, String> jobPropertyMap = new HashMap<String, String>();
		
		if(type == null || "job".equals(type)) {
			String[] names = new String[]{
					"mapred.mapper.class",
					"mapred.reducer.class",	 
					"mapred.combiner.class",	 
					"mapred.input.dir",
					"mapred.output.dir",
					"mapred.output.key.class",
					"mapred.output.value.class",
					"mapred.input.format.class",
					"mapred.output.format.class",
					"mapred.child.java.opts",
					"mapred.map.tasks",
					"mapred.reduce.tasks",
					"mapred.job.queue.name",
					"mapred.map.max.attempts",
					"mapred.reduce.max.attempts",
					"mapred.map.tasks.speculative.execution",
					"mapred.reduce.tasks.speculative.execution",
					"mapred.combiner.class",
					"mapred.compress.map.output",
					"mapred.partitioner.class",
					"mapred.output.compress",
					"mapred.output.compression.codec"
			};
			JobConf conf = new JobConf();
			
			for(String name: names) {
				jobPropertyMap.put(name, conf.get(name));
			}
		} else {
			HiveConf hiveConf = new HiveConf();
			for(Object name: hiveConf.getAllProperties().keySet()) {
				jobPropertyMap.put(name.toString(), hiveConf.get(name.toString()));
			}
		}
		
		return jobPropertyMap;
	}
	
	public List<OozieHiveQuery> getHiveQueries() throws Exception {
		List<HiveConnection> connections = hiveMetaStoreService.getConnections();
		
		List<OozieHiveQuery> oozieHiveQueries = new ArrayList<OozieHiveQuery>();
		if(connections != null) {
			for(HiveConnection eachConn: connections) {
				List<HiveQuery> queries = hiveQueryService.getHiveQueryList(eachConn.getId());
				if(queries != null) {
					for(HiveQuery eachQuery: queries) {
						OozieHiveQuery query = new OozieHiveQuery();
						query.setCategory(eachQuery.getCategoryName());
						query.setQuery(eachQuery.getQuery());
						query.setQueryName(eachQuery.getQueryName());
						query.setCreatedAt(eachQuery.getCreateDate().getTime());
						
						oozieHiveQueries.add(query);
					}
				}
			}
		}
		
//		if(oozieHiveQueries.isEmpty()) {
//			OozieHiveQuery query1 = new OozieHiveQuery();
//			query1.setCategory("test_ca");
//			query1.setQuery("select");
//			query1.setQueryName("query1");
//			query1.setCreatedAt(System.currentTimeMillis());
//			
//			oozieHiveQueries.add(query1);
//			
//			OozieHiveQuery query2 = new OozieHiveQuery();
//			query2.setCategory("test_ca");
//			query2.setQuery("select * from");
//			query2.setQueryName("query2");
//			query2.setCreatedAt(System.currentTimeMillis());
//			
//			oozieHiveQueries.add(query2);
//		}
		
		return oozieHiveQueries;
	}
	
	@Override
	public OozieClusterInfo getOozieClusterInfo() throws Exception {
		OozieClusterInfo oozieClusterInfo = new OozieClusterInfo();
		
		List<HadoopCluster> hadoops = hadoopService.listHadoopClusters();
		
		List<String> nameNodes = new ArrayList<String>();
		if(hadoops != null) {
			for(HadoopCluster eachHadoop: hadoops) {
				nameNodes.add("hdfs://" + eachHadoop.getClusterName());
			}
		}
		oozieClusterInfo.setNameNodes(nameNodes);
		
		List<String> jobTrackers = new ArrayList<String>();
		hadoops = mapReduceService.listMapReduceClusters();
		if(hadoops != null) {
			for(HadoopCluster eachHadoop: hadoops) {
				jobTrackers.add(eachHadoop.getClusterName());
			}
		}
		oozieClusterInfo.setJobTrackers(jobTrackers);
		
		String appRootPath = confService.get("cloumon.oozie.appRootPath", "hdfs://127.0.0.1:9000/tmp/oozie/app");
		
		oozieClusterInfo.setAppRootPath(appRootPath);
		return oozieClusterInfo;
	}
	
	static void validateJobConfiguration(Configuration conf) throws XServletException {
		if (conf.get(OozieClient.USER_NAME) == null) {
			throw new XServletException(HttpServletResponse.SC_BAD_REQUEST, ErrorCode.E0401, OozieClient.USER_NAME);
		}
	}
	
	@Override
	public List<ScheduledJob> getScheduledJobs() {
		List<OozieJob> jobs;
		try {
			jobs = this.listOozieJob();
		} catch (Exception e) {
			LOG.error(e.getMessage(), e);
			return new ArrayList<ScheduledJob>();
		}
		
		List<ScheduledJob> result = new ArrayList<ScheduledJob>(jobs);
		return result;
	}

	@Override
	public void runScheduledJob(ScheduledJob job) {
		try {
			this.runJob(job.getJobName());
		} catch (Exception e) {
			LOG.error(e.getMessage(), e);
		}
	}

	private void sendMail(OozieJob job, OozieJobStatus jobStatus) throws Exception {
		String subject = "[" + job.getJobName() + ", " + jobStatus.getId()+ "] finished. status[" + job.getLastStatus() + "]";
		String log = this.getJobLog(jobStatus.getId());

		String mailTo = job.getMailTo();
		if(mailTo == null || mailTo.isEmpty()) {
			return;
		}
		Map<String, String> messageParams = new HashMap<String, String>();
		if(log != null) {
			log = log.replaceAll("\n", "<br/>");
		}
		messageParams.put("body", log);
		alarmService.sendAlarm("oozie", "default", "", "INFO", subject, Arrays.asList(mailTo.split(",")), messageParams);
	}
	
	class JobStatusChecker extends Thread {
		String jobId;
		String jobName;
		String mailTo;
		
		public JobStatusChecker(String jobId, String jobName) {
			this(jobId, jobName, null);
		}
		public JobStatusChecker(String jobId, String jobName, String mailTo) {
			this.jobId = jobId;
			this.jobName = jobName;
			this.mailTo = mailTo;
		}
		@Override
		public void run() {
			try {
				LOG.info("Start JobStatusChecker:" + jobName + "," + jobId);
				while(true) {
					try {
						OozieJobStatus jobStatus = WorkflowService.this.getOozieJobStatus(jobId);
						if(jobStatus.getEndTime() > 0) {
							OozieJob job = WorkflowService.this.getOozieJob(jobName);
							String status = jobStatus.getStatus();
							if(job != null) {
								job.setLastStatus(status);
								
								WorkflowService.this.saveJob(job);
								if("Y".equals(job.getMailOnlyFail())) {
					        if("KILLED".equals(status) || "FAILED".equals(status) || "ERROR".equals(status)) {
					        	try {
					        		sendMail(job, jobStatus);
					        	} catch (Exception e) {
					        		LOG.error(e.getMessage(), e);
					        		break;
					        	}
					        }
								} else {
				        	try {
				        		sendMail(job, jobStatus);
				        	} catch (Exception e) {
				        		LOG.error(e.getMessage(), e);
				        		break;
				        	}
								}
							} else {
								//run app direct
								if(mailTo != null && !mailTo.isEmpty()) {
									job = new OozieJob();
									job.setJobName(jobName);
									job.setLastJobId(jobId);
									job.setLastStatus(status);
									job.setMailTo(mailTo);

									sendMail(job, jobStatus);								
								}
							}
							break;
						}
					} catch (Exception e) {
						LOG.error(e.getMessage(), e);
					}
					Thread.sleep(30 * 1000);
				}
			} catch (InterruptedException e) {
			} finally {
				synchronized(WorkflowService.this.jobStatusCheckers) {
					WorkflowService.this.jobStatusCheckers.remove(jobId);
				}
				LOG.info("Finish JobStatusChecker:" + jobName + "," + jobId);
			}
		}
	}
	
	public static void main(String[] args) throws Exception {
		// Pattern varPat = Pattern.compile("\\$\\{[^\\}\\$\u0020]+\\}");
		// BufferedReader reader = new BufferedReader(new
		// FileReader("/Users/babokim/workspace/gruter_oozie_designer/sample.xml"));
		//		
		// String data = "";
		// String line = null;
		// while( (line = reader.readLine()) != null ) {
		// data += line + "\n";
		// }
		// reader.close();
		//
		// Matcher matcher = varPat.matcher(data);
		// while(matcher.find()) {
		// String variable = data.substring(matcher.start(), matcher.end());
		// if(!variable.startsWith("${wf:")) {
		// System.out.println(variable);
		// }
		// }

		// Properties properties = new Properties();
		// properties.put("nameNode",
		// "hdfs://hyungjoon-kim-ui-MacBook-Pro.local:9000");
		// properties.put("jobTracker", "hyungjoon-kim-ui-MacBook-Pro.local:9001");
		// properties.put("queueName", "default");
		// properties.put("examplesRoot", "examples");
		// properties.put("oozie.wf.application.path",
		// "hdfs://hyungjoon-kim-ui-MacBook-Pro.local:9000/user/babokim/examples/apps/map-reduce");
		// properties.put("outputDir", "map-reduce-" + System.currentTimeMillis());
		// properties.put(OozieClient.USER_NAME, "babokim");

//		XConfiguration conf = new XConfiguration();
//		conf.set("nameNode", "hdfs://hyungjoon-kim-ui-MacBook-Pro.local:9000");
//		conf.set("jobTracker", "hyungjoon-kim-ui-MacBook-Pro.local:9001");
//		conf.set("queueName", "default");
//		conf.set("examplesRoot", "examples");
//		conf.set("oozie.wf.application.path", "hdfs://hyungjoon-kim-ui-MacBook-Pro.local:9000/user/babokim/examples/apps/map-reduce");
//		conf.set("outputDir", "map-reduce-" + System.currentTimeMillis());
//		conf.set(OozieClient.USER_NAME, "babokim");
//
//		WorkflowService service = new WorkflowService();
//		String jobId = service.runOozieJob(null, conf);
//
//		System.out.println("====================> job started:" + jobId);
//		while (true) {
//			Thread.sleep(10 * 1000);
//			WorkflowJob oozieAppJobStatus = service.getOozieJobStatus(jobId);
//			System.out.println("===========================");
//			for (WorkflowAction action : oozieAppJobStatus.getActions()) {
//				System.out.println(action.getExternalId() + "," + action.getStatus());
//			}
//		}
	}
}
