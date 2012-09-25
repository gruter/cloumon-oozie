package org.cloumon.gruter.oozie.model;

import java.util.List;
import java.util.Map;

public class AppLibFile {
	private String appName;
	private String fileName;
	private String libPath;
	private String fullPath;
	private long length;
	private long lastModifiedTime;
	
	//class type -> class list
	private Map<String, List<String>> classList;
	
	public String getFileName() {
		return fileName;
	}
	public void setFileName(String fileName) {
		this.fileName = fileName;
	}
	public String getFullPath() {
		return fullPath;
	}
	public void setFullPath(String fullPath) {
		this.fullPath = fullPath;
	}
	public long getLength() {
		return length;
	}
	public void setLength(long length) {
		this.length = length;
	}
	public long getLastModifiedTime() {
		return lastModifiedTime;
	}
	public void setLastModifiedTime(long lastModifiedTime) {
		this.lastModifiedTime = lastModifiedTime;
	}
	public Map<String, List<String>> getClassList() {
		return classList;
	}
	public void setClassList(Map<String, List<String>> classList) {
		this.classList = classList;
	}
	public String getAppName() {
		return appName;
	}
	public void setAppName(String appName) {
		this.appName = appName;
	}
	public String getLibPath() {
		return libPath;
	}
	public void setLibPath(String libPath) {
		this.libPath = libPath;
	}
}
