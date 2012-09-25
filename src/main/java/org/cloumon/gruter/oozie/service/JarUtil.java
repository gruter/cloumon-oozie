package org.cloumon.gruter.oozie.service;

import java.io.File;
import java.net.URL;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;

public class JarUtil {
	private static boolean isMatch(Class targetClass, Class loadedClass) {
		if (targetClass.equals(loadedClass)) {
			return true;
		}

		// then get an array of all the interfaces in our class
		Class[] classInterfaces = loadedClass.getInterfaces();
		if (classInterfaces != null) {
			for (Class eachInterfaceClass : classInterfaces) {
				if (eachInterfaceClass.equals(targetClass)) {
					return true;
				}

				if (isMatch(targetClass, eachInterfaceClass)) {
					return true;
				}
			}
		}

		Class superClass = loadedClass.getSuperclass();
		if (superClass != null) {
			if (isMatch(targetClass, superClass)) {
				return true;
			}
		}
		return false;
	}

	public static Map<String, List<String>> findClass(Configuration conf, Path jarPath, Class[] targetClasses) throws Exception {
		ClosableURLClassLoader cl = null;
		String localTempFilePath = null;
		try {
			FileSystem fs = jarPath.getFileSystem(conf);
			localTempFilePath = System.getProperty("user.dir") + "/tmp/" + + System.currentTimeMillis() + "_" + jarPath.getName();
			fs.copyToLocalFile(jarPath, new Path(localTempFilePath));
			
			File file = new File(localTempFilePath);
			URL jarUrl = new URL("file:" + file.getAbsolutePath());
			cl = new ClosableURLClassLoader(new URL[] { jarUrl }, JarUtil.class.getClassLoader());

			Set<Class> allClasses = new HashSet<Class>();
			
			JarFile jarFile = new JarFile(file);
			Enumeration<JarEntry> enumeration = jarFile.entries();
			while (enumeration.hasMoreElements()) {
				JarEntry jarEntry = enumeration.nextElement();
				if (jarEntry.getName().endsWith(".class")) {
					Class loadedClass = cl.loadClass(jarEntry.getName().replace("/", ".").substring(0, jarEntry.getName().lastIndexOf(".class")));
					allClasses.add(loadedClass);
				}
			}

			Map<String, List<String>> result = new HashMap<String, List<String>>();
			
			List<Class> addedClass = new ArrayList<Class>();
			
			for(Class eachClass: allClasses) {
				for(Class eachTargetClass: targetClasses) {
					if(isMatch(eachTargetClass, eachClass)) {
						List<String> matchedClasses = result.get(eachTargetClass.getName());
						if(matchedClasses == null) {
							matchedClasses = new ArrayList<String>();
							result.put(eachTargetClass.getName(), matchedClasses);
						}
						matchedClasses.add(eachClass.getCanonicalName());
						
						addedClass.add(eachClass);
					}
				}
			}

			for(Class eachClass: addedClass) {
				allClasses.remove(eachClass);
			}
			
			List<String> others = new ArrayList<String>();
			for(Class eachClass: allClasses) {
				others.add(eachClass.getCanonicalName());
			}
			result.put("others", others);
			
			return result;
		} finally {
			if (cl != null) {
				try {
					cl.close();
				} catch (Exception e) {
				}
			}
			if(localTempFilePath != null) {
				File file = new File(localTempFilePath);
				file.delete();
				File crcFile = new File(file.getParentFile(), "." + file.getName() + ".crc");
				crcFile.delete();
			}
		}
	}
	
	public static List<String> findClass(Configuration conf, Path jarPath, Class targetClass) throws Exception {
		ClosableURLClassLoader cl = null;
		String localTempFilePath = null;
		try {
			FileSystem fs = jarPath.getFileSystem(conf);
			localTempFilePath = System.getProperty("user.dir") + "/tmp/" + + System.currentTimeMillis() + "_" + jarPath.getName();
			fs.copyToLocalFile(jarPath, new Path(localTempFilePath));
			
			File file = new File(localTempFilePath);
			URL jarUrl = new URL("file:" + file.getAbsolutePath());
			cl = new ClosableURLClassLoader(new URL[] { jarUrl }, JarUtil.class.getClassLoader());

			List<String> matchedClasses = new ArrayList<String>();
			
			JarFile jarFile = new JarFile(file);
			Enumeration<JarEntry> enumeration = jarFile.entries();
			while (enumeration.hasMoreElements()) {
				JarEntry jarEntry = enumeration.nextElement();
				if (jarEntry.getName().endsWith(".class")) {
					Class loadedClass = cl.loadClass(jarEntry.getName().replace("/", ".").substring(0, jarEntry.getName().lastIndexOf(".class")));
					if(isMatch(targetClass, loadedClass)) {
						matchedClasses.add(loadedClass.getCanonicalName());
					}
				}
			}
			
			return matchedClasses;
		} finally {
			if (cl != null) {
				try {
					cl.close();
				} catch (Exception e) {
				}
			}
			if(localTempFilePath != null) {
				File file = new File(localTempFilePath);
				file.delete();
				File crcFile = new File(file.getParentFile(), "." + file.getName() + ".crc");
				crcFile.delete();
			}
		}
	}
	
	public static void main(String[] args) throws Exception {
//		for(String eachClass: JarUtil.findClass(new Configuration(), 
//				new Path("hdfs://hyungjoon-kim-ui-MacBook-Pro.local:9000/user/babokim/examples/apps/map-reduce/lib/oozie-examples-3.2.0-incubating.jar"), 
//				Mapper.class)) {
//			System.out.println(">>>>" + eachClass);
//		}
		
//		String path = "/Users/babokim/workspace/cloumon_enterprise/tmp/1346207723479_oozie-examples-3.2.0-incubating.jar";
//		File file = new File(path);
//		URL jarUrl = new URL("file:" + file.getAbsolutePath());
//		ClosableURLClassLoader cl = new ClosableURLClassLoader(new URL[] { jarUrl }, JarUtil.class.getClassLoader());
//
//		JarFile jarFile = new JarFile(file);
//		Enumeration<JarEntry> enumeration = jarFile.entries();
//		while (enumeration.hasMoreElements()) {
//			JarEntry jarEntry = enumeration.nextElement();
//			if (jarEntry.getName().endsWith(".class")) {
//				Class loadedClass = cl.loadClass(jarEntry.getName().replace("/", ".").substring(0, jarEntry.getName().lastIndexOf(".class")));
//				System.out.println("class>>>" + loadedClass);
//				if(isMatch(Mapper.class, loadedClass)) {
//					System.out.println("map class>>>" + loadedClass);
//				}
//			}
//		}
	}
}
