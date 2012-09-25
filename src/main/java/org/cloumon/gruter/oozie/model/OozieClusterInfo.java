package org.cloumon.gruter.oozie.model;

import java.util.List;

public class OozieClusterInfo {
	private String appRootPath;
	private List<String> jobTrackers;
	private List<String> nameNodes;
	
	public String getAppRootPath() {
		return appRootPath;
	}
	public void setAppRootPath(String appRootPath) {
		this.appRootPath = appRootPath;
	}
	public List<String> getJobTrackers() {
		return jobTrackers;
	}
	public void setJobTrackers(List<String> jobTrackers) {
		this.jobTrackers = jobTrackers;
	}
	public List<String> getNameNodes() {
		return nameNodes;
	}
	public void setNameNodes(List<String> nameNodes) {
		this.nameNodes = nameNodes;
	}
}
