package org.cloumon.gruter.oozie.web;

import java.io.IOException;
import java.util.HashMap;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletResponse;

import org.cloumon.gruter.common.BaseController;
import org.cloumon.gruter.oozie.model.OozieApp;
import org.cloumon.gruter.oozie.model.OozieJob;
import org.cloumon.gruter.oozie.service.IWorkflowService;
import org.cloumon.gruter.oozie.service.WorkflowService;
import org.codehaus.jackson.JsonGenerationException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.type.TypeReference;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

@Controller
public class WorkflowController extends BaseController{
	@Resource(type=WorkflowService.class)
  private IWorkflowService workflowService;

  @RequestMapping(value = "workflow/workflow.do")
  protected ModelAndView getWorkflowView() throws Exception {
  	return new ModelAndView("workflow/workflow");
  }

  @RequestMapping(value = "workflow/workflowFrame.do")
  protected ModelAndView getWorkflowFrameView() throws Exception {
  	return new ModelAndView("workflow/workflow_frame");
  }

  @RequestMapping(value = "workflow/jobstatus.do")
  protected ModelAndView getJobStatusView() throws Exception {
  	return new ModelAndView("workflow/jobstatus");
  }

  @RequestMapping(value = "workflow/jobstatusFrame.do")
  protected ModelAndView getJobStatusFrameView() throws Exception {
  	return new ModelAndView("workflow/jobstatus_frame");
  }
  
  @RequestMapping(value = "workflow/listApp.do")
  protected @ResponseBody Object listApp() throws Exception {
  	try {
  		return this.createSuccessResponse(workflowService.listOozieApp());
  	} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/findProperty.do")
  protected @ResponseBody Object findProperties(
  		@RequestParam(value="xml", required=true) String xml) throws Exception {
  	try {
  		return this.createSuccessResponse(workflowService.findProperties(xml, false));
  	} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/dummy.do")
  protected @ResponseBody Object dummy() throws Exception {
  	try {
  		return this.createSuccessResponse("OK");
  	} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/saveApp.do")
	protected @ResponseBody Object saveApp (
			@RequestParam(value="appName", required=true) String appName,
			@RequestParam(value="appXml", required=true) String appXml,
			@RequestParam(value="positions", required=true) String positions,
			@RequestParam(value="creator", required=false) String creator,
			@RequestParam(value="description", required=false) String description,
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
  	try {
  		OozieApp app = new OozieApp();
  	
  		app.setAppName(appName);
  		app.setXml(appXml);
  		app.setCreator(creator);
  		app.setDescription(description);
  		app.setPositions(positions);
  		
  		workflowService.saveApp(app);
			return this.createSuccessResponse("Success");
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/deleteApp.do")
	protected @ResponseBody Object deleteApp (
			@RequestParam(value="appName", required=true) String appName,
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
  	try {
  		workflowService.deleteOozieApp(appName);
			return this.createSuccessResponse("Success");
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/getApp.do")
	protected @ResponseBody Object getApp (
			@RequestParam(value="appName", required=true) String appName,
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
  	try {
			return this.createSuccessResponse(workflowService.getOozieApp(appName));
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/saveJob.do")
	protected @ResponseBody Object saveJob (
			@RequestParam(value="jobName", required=true) String jobName,
			@RequestParam(value="appName", required=true) String appName,
			@RequestParam(value="userName", required=true) String userName,
			@RequestParam(value="mailTo", required=false) String mailTo,
			@RequestParam(value="mailOnlyFail", required=false) String mailOnlyFail,
			@RequestParam(value="scheduleInfo", required=true) String scheduleInfo,
			@RequestParam(value="jobParams", required=false) String jobParams,
			@RequestParam(value="description", required=false) String description,
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
  	try {
  		OozieJob job = new OozieJob();
  	
   		job.setJobName(jobName);
   		job.setAppName(appName);
  		job.setScheduleInfo(scheduleInfo);
  		job.setJobParams(jobParams);
  		job.setDescription(description);
  		job.setUserName(userName);
  		job.setMailOnlyFail(mailOnlyFail);
  		job.setMailTo(mailTo);
			workflowService.saveJob(job);
			return this.createSuccessResponse("Success");
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/listJob.do")
  protected @ResponseBody Object listJob(
  		@RequestParam(value="appName", required=false) String appName) throws Exception {
  	try {
  		if(appName == null || appName.isEmpty()) {
    		return this.createSuccessResponse(workflowService.listOozieJob());
  		} else {
    		return this.createSuccessResponse(workflowService.listOozieJobByApp(appName));
  		}
  	} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/getJob.do")
  protected @ResponseBody Object getJob(
  		@RequestParam(value="jobName", required=true) String jobName) throws Exception {
  	try {
    		return this.createSuccessResponse(workflowService.getOozieJob(jobName));
  	} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/deleteJob.do")
	protected @ResponseBody Object deleteJob (
			@RequestParam(value="jobName", required=true) String jobName,
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
  	try {
  		workflowService.deleteOozieJob(jobName);
			return this.createSuccessResponse("Success");
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/runApp.do")
	protected @ResponseBody Object runApp (
			@RequestParam(value="appName", required=true) String appName,
			@RequestParam(value="userName", required=true) String userName,
			@RequestParam(value="mailTo", required=false) String mailTo,
			@RequestParam(value="jobParams", required=true) String jobParams,
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
  	try {
  		
  		HashMap<String, String> params = WorkflowService.om.readValue(jobParams, new TypeReference<HashMap<String, String>>(){});
			return this.createSuccessResponse(workflowService.runApp(appName, userName, mailTo, params));
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/runJob.do")
	protected @ResponseBody Object runJob (
			@RequestParam(value="jobName", required=true) String jobName,
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
  	try {
			return this.createSuccessResponse(workflowService.runJob(jobName));
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/killJob.do")
	protected @ResponseBody Object killJob (
			@RequestParam(value="jobId", required=true) String jobId,
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
  	try {
  		workflowService.killJob(jobId);
			return this.createSuccessResponse("Success");
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }  

  @RequestMapping(value = "workflow/resumeJob.do")
	protected @ResponseBody Object resumeJob (
			@RequestParam(value="jobId", required=true) String jobId,
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
  	try {
  		workflowService.resumeJob(jobId);
			return this.createSuccessResponse("Success");
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }  
  
  @RequestMapping(value = "workflow/suspendJob.do")
	protected @ResponseBody Object suspendJob (
			@RequestParam(value="jobId", required=true) String jobId,
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
  	try {
  		workflowService.suspendJob(jobId);
			return this.createSuccessResponse("Success");
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }  

  @RequestMapping(value = "workflow/getJobHistory.do")
	protected @ResponseBody Object getJobHistory (
			@RequestParam(value="jobName", required=false) String jobName,
			@RequestParam(value="from", required=false) String from,
			@RequestParam(value="to", required=false) String to,
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
  	try {
			return this.createSuccessResponse(workflowService.getJobHistory(jobName, from, to));
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/getJobStatus.do")
	protected @ResponseBody Object getJobStatus (
			@RequestParam(value="jobId", required=true) String jobId,
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
  	try {
			return this.createSuccessResponse(workflowService.getOozieJobStatus(jobId));
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/getJobLog.do")
	protected @ResponseBody Object getJobLog (
			@RequestParam(value="jobId", required=true) String jobId,
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
  	try {
			return this.createSuccessResponse(workflowService.getJobLog(jobId));
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/getAppLibFiles.do")
	protected @ResponseBody Object getAppLibFiles (
			@RequestParam(value="appName", required=true) String appName,
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
  	try {
			return this.createSuccessResponse(workflowService.getAppLibFiles(appName));
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/getAppLibFile.do")
	protected @ResponseBody Object getAppLibFile (
			@RequestParam(value="filePath", required=true) String filePath,
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
  	try {
			return this.createSuccessResponse(workflowService.getAppLibFile(filePath));
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/removeAppLibFile.do")
	protected @ResponseBody Object removeAppLibFile (
			@RequestParam(value="appName", required=true) String appName,
			@RequestParam(value="fileName", required=true) String fileName,
			@RequestParam(value="libPath", required=false) String libPath,
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
  	try {
  		workflowService.removeAppLibFile(appName, fileName, libPath);
			return this.createSuccessResponse("Success");
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/getDefaultJobProperties.do")
	protected @ResponseBody Object getDefaultJobProperties (
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
  	try {
			return this.createSuccessResponse(workflowService.getDefaultJobProperties("job"));
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/getDefaultHiveProperties.do")
	protected @ResponseBody Object getDefaultHiveProperties (
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
  	try {
			return this.createSuccessResponse(workflowService.getDefaultJobProperties("hive"));
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/getHiveQuery.do")
	protected @ResponseBody Object getHiveQuery (
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
  	try {
			return this.createSuccessResponse(workflowService.getHiveQueries());
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/saveQuery.do")
	protected @ResponseBody Object saveQuery (
			@RequestParam(value="appName", required=true) String appName,
			@RequestParam(value="queryFile", required=true) String queryFile,
			@RequestParam(value="query", required=true) String query,
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
  	try {
			return this.createSuccessResponse(workflowService.saveQuery(appName, queryFile, query));
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/getQuery.do")
	protected @ResponseBody Object getQuery (
			@RequestParam(value="appName", required=true) String appName,
			@RequestParam(value="queryFile", required=true) String queryFile,
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
  	try {
			return this.createSuccessResponse(workflowService.getQuery(appName, queryFile));
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value = "workflow/getOozieClusterInfo.do")
	protected @ResponseBody Object getOozieClusterInfo (
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
  	try {
			return this.createSuccessResponse(workflowService.getOozieClusterInfo());
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
  
  @RequestMapping(value="workflow/callback.do") 
  protected @ResponseBody Object callback(@RequestParam(value="id", required=true) String actionId,
			@RequestParam(value="status", required=true) String status,
			HttpServletResponse response) throws JsonGenerationException,
			JsonMappingException, IOException {
    int idx = actionId.lastIndexOf('@', actionId.length());
    String jobId;
    if (idx == -1) {
        jobId = actionId;
    }
    else {
        jobId = actionId.substring(0, idx);
    }
    
    try {
			workflowService.callback(jobId, actionId, status);
	    return "Success";
		} catch (Exception e) {
			return createFailureResponse(e.getMessage(), e);
		}
  }
}
