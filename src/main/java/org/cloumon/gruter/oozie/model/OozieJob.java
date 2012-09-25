package org.cloumon.gruter.oozie.model;

import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.cloumon.gruter.oozie.service.WorkflowService;
import org.cloumon.gruter.oozie.service.timer.ScheduledJob;
import org.codehaus.jackson.type.TypeReference;

public class OozieJob implements ScheduledJob {
	private String appName;
	private String jobName;
	private String userName;
	private String mailTo;
	private String mailOnlyFail;
	private String xml;							//readonly
	private String description;
	private String scheduleInfo;
	private String jobParams;				//readonly
	private String lastJobId;
	private String lastStatus;
	private Timestamp lastExecutionTime;
	
	private Map<String, String> jobParamMap = new HashMap<String, String>();
	private List<OozieJobHistory> jobHistories;
	
	public String getAppName() {
		return appName;
	}
	public void setAppName(String appName) {
		this.appName = appName;
	}
	public String getJobName() {
		return jobName;
	}
	public void setJobName(String jobName) {
		this.jobName = jobName;
	}
	public String getXml() {
		return xml;
	}
	public void setXml(String xml) {
		this.xml = xml;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public String getJobParams() {
		return jobParams;
	}
	public void setJobParams(String jobParams) {
		this.jobParams = jobParams;
		if(jobParams != null) {
			try {
				this.jobParamMap = WorkflowService.om.readValue(jobParams, new TypeReference<HashMap<String, String>>(){});
			} catch (Exception e) {
				WorkflowService.LOG.warn(e.getMessage(), e);
			}
		}
	}
	public Map<String, String> getJobParamMap() {
		return jobParamMap;
	}
	public String getScheduleInfo() {
		return scheduleInfo;
	}
	public void setScheduleInfo(String scheduleInfo) {
		this.scheduleInfo = scheduleInfo;
	}
	public void setJobParamMap(Map<String, String> jobParamMap) {
		this.jobParamMap = jobParamMap;
	}
	public String getLastStatus() {
		return lastStatus;
	}
	public void setLastStatus(String lastStatus) {
		this.lastStatus = lastStatus;
	}
	public Timestamp getLastExecutionTime() {
		return lastExecutionTime;
	}
	public void setLastExecutionTime(Timestamp lastExecutionTime) {
		this.lastExecutionTime = lastExecutionTime;
	}
	public String getLastJobId() {
		return lastJobId;
	}
	public void setLastJobId(String lastJobId) {
		this.lastJobId = lastJobId;
	}
	public List<OozieJobHistory> getJobHistories() {
		return jobHistories;
	}
	public void setJobHistories(List<OozieJobHistory> jobHistories) {
		this.jobHistories = jobHistories;
	}
	public String getUserName() {
		return userName;
	}
	public void setUserName(String userName) {
		this.userName = userName;
	}
	public String getMailTo() {
		return mailTo;
	}
	public void setMailTo(String mailTo) {
		this.mailTo = mailTo;
	}
	public String getMailOnlyFail() {
		return mailOnlyFail;
	}
	public void setMailOnlyFail(String mailOnlyFail) {
		this.mailOnlyFail = mailOnlyFail;
	}
}
