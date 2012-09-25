package org.cloumon.gruter.oozie.service.external;

public interface IConfService {

	public String get(String key, String defaultValue);
	public String get(String key);
	public boolean getBoolean(String ket, boolean defaultValue);

}
