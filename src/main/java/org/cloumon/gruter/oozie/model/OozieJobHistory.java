package org.cloumon.gruter.oozie.model;

import java.sql.Timestamp;

public class OozieJobHistory {
	private String jobName;
	private String jobId;
	private Timestamp execTime;
	
	public String getJobName() {
		return jobName;
	}
	public void setJobName(String jobName) {
		this.jobName = jobName;
	}
	public String getJobId() {
		return jobId;
	}
	public void setJobId(String jobId) {
		this.jobId = jobId;
	}
	public Timestamp getExecTime() {
		return execTime;
	}
	public void setExecTime(Timestamp execTime) {
		this.execTime = execTime;
	}
}
