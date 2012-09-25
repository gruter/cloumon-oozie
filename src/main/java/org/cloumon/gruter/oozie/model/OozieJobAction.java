package org.cloumon.gruter.oozie.model;

import org.apache.oozie.client.WorkflowAction;


public class OozieJobAction {
  private String id;
  private String name;
  private String cred;
  private String type;
  private String conf;
  private String status;
  private int retries;
  private int userRetryCount;
  private int userRetryMax;
  private int userRetryInterval;
  private long startTime;
  private long endTime;
  private String transition;
  private String data;
  private String stats;
  private String externalChildIDs;
  private String externalId;
  private String externalStatus;
  private String trackerUri;
  private String consoleUrl;
  private String errorCode;
  private String errorMessage;
  
	public OozieJobAction() {
		
	}
	
	public OozieJobAction(WorkflowAction eachAction) {
	  this.id = eachAction.getId();
	  this.name = eachAction.getName();
	  this.cred = eachAction.getCred();
	  this.type = eachAction.getType();
	  this.conf = eachAction.getConf();
	  this.status = eachAction.getStatus().toString();
	  this.retries = eachAction.getRetries();
	  this.userRetryCount = eachAction.getUserRetryCount();
	  this.userRetryMax = eachAction.getUserRetryMax();
	  this.userRetryInterval = eachAction.getUserRetryInterval();
	  if(eachAction.getStartTime() != null) {
	  	this.startTime = eachAction.getStartTime().getTime();
	  }
	  
	  if(eachAction.getEndTime() != null) {
	  	this.endTime = eachAction.getEndTime().getTime();
	  }
	  this.transition = eachAction.getTransition();
	  this.data = eachAction.getData();
	  this.stats = eachAction.getStats();
	  this.externalChildIDs = eachAction.getExternalChildIDs();
	  this.externalId = eachAction.getExternalId();
	  this.externalStatus = eachAction.getExternalStatus();
	  this.trackerUri = eachAction.getTrackerUri();
	  this.consoleUrl = eachAction.getConsoleUrl();
	  this.errorCode = eachAction.getErrorCode();
	  this.errorMessage = eachAction.getErrorMessage();
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getCred() {
		return cred;
	}

	public void setCred(String cred) {
		this.cred = cred;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
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

	public int getRetries() {
		return retries;
	}

	public void setRetries(int retries) {
		this.retries = retries;
	}

	public int getUserRetryCount() {
		return userRetryCount;
	}

	public void setUserRetryCount(int userRetryCount) {
		this.userRetryCount = userRetryCount;
	}

	public int getUserRetryMax() {
		return userRetryMax;
	}

	public void setUserRetryMax(int userRetryMax) {
		this.userRetryMax = userRetryMax;
	}

	public int getUserRetryInterval() {
		return userRetryInterval;
	}

	public void setUserRetryInterval(int userRetryInterval) {
		this.userRetryInterval = userRetryInterval;
	}

	public long getStartTime() {
		return startTime;
	}

	public void setStartTime(long startTime) {
		this.startTime = startTime;
	}

	public long getEndTime() {
		return endTime;
	}

	public void setEndTime(long endTime) {
		this.endTime = endTime;
	}

	public String getTransition() {
		return transition;
	}

	public void setTransition(String transition) {
		this.transition = transition;
	}

	public String getData() {
		return data;
	}

	public void setData(String data) {
		this.data = data;
	}

	public String getStats() {
		return stats;
	}

	public void setStats(String stats) {
		this.stats = stats;
	}

	public String getExternalChildIDs() {
		return externalChildIDs;
	}

	public void setExternalChildIDs(String externalChildIDs) {
		this.externalChildIDs = externalChildIDs;
	}

	public String getExternalId() {
		return externalId;
	}

	public void setExternalId(String externalId) {
		this.externalId = externalId;
	}

	public String getExternalStatus() {
		return externalStatus;
	}

	public void setExternalStatus(String externalStatus) {
		this.externalStatus = externalStatus;
	}

	public String getTrackerUri() {
		return trackerUri;
	}

	public void setTrackerUri(String trackerUri) {
		this.trackerUri = trackerUri;
	}

	public String getConsoleUrl() {
		return consoleUrl;
	}

	public void setConsoleUrl(String consoleUrl) {
		this.consoleUrl = consoleUrl;
	}

	public String getErrorCode() {
		return errorCode;
	}

	public void setErrorCode(String errorCode) {
		this.errorCode = errorCode;
	}

	public String getErrorMessage() {
		return errorMessage;
	}

	public void setErrorMessage(String errorMessage) {
		this.errorMessage = errorMessage;
	}
}
