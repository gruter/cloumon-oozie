package org.cloumon.gruter.oozie.service;

import java.lang.reflect.Field;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.Collection;
import java.util.jar.JarFile;

public class ClosableURLClassLoader extends URLClassLoader {

	public ClosableURLClassLoader(URL[] urls, ClassLoader parent) {
		super(urls, parent);
	}

	/**
	 * Closes all open jar files
	 */
	public void close() {
		try {
			Class clazz = java.net.URLClassLoader.class;
			Field ucp = clazz.getDeclaredField("ucp");
			ucp.setAccessible(true);
			Object sunMiscURLClassPath = ucp.get(this);
			Field loaders = sunMiscURLClassPath.getClass().getDeclaredField("loaders");
			loaders.setAccessible(true);
			Object collection = loaders.get(sunMiscURLClassPath);
			for (Object sunMiscURLClassPathJarLoader : ((Collection) collection).toArray()) {
				try {
					Field loader = sunMiscURLClassPathJarLoader.getClass().getDeclaredField("jar");
					loader.setAccessible(true);
					Object jarFile = loader.get(sunMiscURLClassPathJarLoader);
					((JarFile) jarFile).close();
				} catch (Throwable t) {
					t.printStackTrace();
					// if we got this far, this is probably not a JAR loader so skip it
				}
			}
		} catch (Throwable t) {
			// probably not a SUN VM
		}
		return;
	}
}