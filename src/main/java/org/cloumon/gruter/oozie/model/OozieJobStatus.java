package org.cloumon.gruter.oozie.model;

import java.io.IOException;
import java.io.StringReader;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.oozie.WorkflowJobBean;
import org.apache.oozie.util.XConfiguration;

public class OozieJobStatus {
	private String appPath;
	private String jobName;
	private String id;
	private String parentId;
	private String conf;
	private String xml;
	private String status;
	private long createdTime;
	private long startTime;
	private long lastModifiedTime;
	private long endTime;
	private String user;
	private String group;
	private int run;
	
	private String consoleUrl;
	
	private List<OozieJobAction> actions;
	
	Map<String, String> configMap = new HashMap<String, String>();
	
	public OozieJobStatus() {
	}
	
	public OozieJobStatus(WorkflowJobBean workflowJobBean) {
		appPath = workflowJobBean.getAppPath();
		jobName = workflowJobBean.getAppName();
		id = workflowJobBean.getId();
		parentId  = workflowJobBean.getParentId();
		conf = workflowJobBean.getConf();
		status = workflowJobBean.getStatusStr();
		
		if(workflowJobBean.getCreatedTime() != null) {
			createdTime = workflowJobBean.getCreatedTime().getTime();
		}
		
		if(workflowJobBean.getStartTime() != null) {
			startTime = workflowJobBean.getStartTime().getTime();
		}
		
		if(workflowJobBean.getLastModifiedTime() != null) {
			lastModifiedTime = workflowJobBean.getLastModifiedTime().getTime();
		}
		
		if(workflowJobBean.getEndTime() != null){		
			endTime = workflowJobBean.getEndTime().getTime();
		}
		user = workflowJobBean.getUser();
		group = workflowJobBean.getGroup();
		run = workflowJobBean.getRun();
		consoleUrl= workflowJobBean.getConsoleUrl();
		
		if(conf != null) {
			StringReader reader = new StringReader(conf);
			try {
				XConfiguration config = new XConfiguration(reader);
				for(Map.Entry<String, String> entry: config) {
					configMap.put(entry.getKey(), entry.getValue());
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	
	public Map<String, String> getConfigMap() {
		return configMap;
	}
	
	public String getAppPath() {
		return appPath;
	}
	public void setAppPath(String appPath) {
		this.appPath = appPath;
	}
	public String getJobName() {
		return jobName;
	}
	public void setJobName(String jobName) {
		this.jobName = jobName;
	}
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getParentId() {
		return parentId;
	}
	public void setParentId(String parentId) {
		this.parentId = parentId;
	}
	public String getConf() {
		return conf;
	}
	public void setConf(String conf) {
		this.conf = conf;
	}
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	public long getCreatedTime() {
		return createdTime;
	}
	public void setCreatedTime(long createdTime) {
		this.createdTime = createdTime;
	}
	public long getStartTime() {
		return startTime;
	}
	public void setStartTime(long startTime) {
		this.startTime = startTime;
	}
	public long getLastModifiedTime() {
		return lastModifiedTime;
	}
	public void setLastModifiedTime(long lastModifiedTime) {
		this.lastModifiedTime = lastModifiedTime;
	}
	public long getEndTime() {
		return endTime;
	}
	public void setEndTime(long endTime) {
		this.endTime = endTime;
	}
	public String getUser() {
		return user;
	}
	public void setUser(String user) {
		this.user = user;
	}
	public String getGroup() {
		return group;
	}
	public void setGroup(String group) {
		this.group = group;
	}
	public int getRun() {
		return run;
	}
	public void setRun(int run) {
		this.run = run;
	}

	public String getConsoleUrl() {
		return consoleUrl;
	}

	public void setConsoleUrl(String consoleUrl) {
		this.consoleUrl = consoleUrl;
	}

	public List<OozieJobAction> getActions() {
		return actions;
	}

	public void setActions(List<OozieJobAction> actions) {
		this.actions = actions;
	}

	public String getXml() {
		return xml;
	}

	public void setXml(String xml) {
		this.xml = xml;
	}
}