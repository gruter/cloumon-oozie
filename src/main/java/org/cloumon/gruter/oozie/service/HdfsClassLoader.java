package org.cloumon.gruter.oozie.service;

import sun.misc.URLClassPath;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.URL;
import java.net.URLClassLoader;
import java.security.AccessControlContext;
import java.util.List;

/**
 * This class loader is able to load classes from hadoop. It accepts a
 * configuration parameter which is the hadoop directory to localize. When the
 * default loaders can't load a class (and not before that) it localizes the
 * hadoop directory, loads it and retries. In case the hadoop directory has
 * already been localized it uses the local copy.
 * <p/>
 */
public class HdfsClassLoader extends URLClassLoader {
  public static final String SYSTEM_CLASSLOADER_NAME = "java.system.class.loader";
  public static final String VERBOSE_PROPERTY_NAME = "org.apache.hadoop.hbase.classloader.verbose";
  public static boolean USE_AS_DEFAULT = false;

  static {
    if (System.getProperty(SYSTEM_CLASSLOADER_NAME, "").compareTo(
        HdfsClassLoader.class.getName()) == 0) {
      USE_AS_DEFAULT = true;
    }
  }

  private static final long WAIT_TIME_MILLIS = 50L;
  private static boolean verbose = Boolean.valueOf(System.getProperty(
      VERBOSE_PROPERTY_NAME, "true"));

  private Class<?> localizerClass;
  private Object classPathLocalizer;

  /**
   * Default constructor.
   * 
   * @throws Exception
   *           in case of an error.
   */
  public HdfsClassLoader() throws Exception {
    this(ClassLoader.getSystemClassLoader());
  }

  /**
   * Create a new instance of Hdfs class loader.
   * 
   * @param parent
   *          the parent class laoder.
   * 
   * @throws Exception
   *           in case of an error.
   */
  public HdfsClassLoader(java.lang.ClassLoader parent) throws Exception {
    super(new URL[0], parent);
    Field ucpField = URLClassLoader.class.getDeclaredField("ucp");
    Field accField = URLClassLoader.class.getDeclaredField("acc");
    ucpField.setAccessible(true);
    accField.setAccessible(true);

    URLClassPath ucp = (URLClassPath) ucpField.get(parent);

    AccessControlContext acc = (AccessControlContext) accField.get(parent);

    ucpField.set(this, ucp);
    accField.set(this, acc);

    ucpField.set(parent, sun.misc.Launcher.getBootstrapClassPath());
  }

  /**
   * Extends the class path on first attempt to find a class. Class path in
   * intentionally not extended from the find resource method, the assumption is
   * that only a transported class may use one of the resources in the
   * transported jars.
   * 
   * @param name
   *          the class nmae
   * 
   * @return the class object
   * 
   * @throws ClassNotFoundException
   *           in case not found
   */
  @SuppressWarnings({ "unchecked" })
  @Override
  protected Class<?> findClass(String name) throws ClassNotFoundException {
    try {
      return super.findClass(name);
    } catch (ClassNotFoundException cne) {
      log("Parent ClassLoader failed to load class " + name);
      /**
       * No need to synchronize since class loading is synchronized anyway (I
       * hope :-)
       */
      boolean isATriggeringClass;

      try {
        initLocalizer();
        isATriggeringClass = callIsATriggeringClass(localizerClass,
            classPathLocalizer, name);
      } catch (Throwable throwable) {
        Throwable cause = throwable.getCause() != null ? throwable.getCause()
            : throwable;
        logError(
            "Failed initiazling or finding out whether the class is a trigger: ",
            cause);
        throw new ClassNotFoundException(throwable.getMessage(), cause);
      }
      if (isATriggeringClass) {

        try {
          log("Trying to load class " + name + " from hadoop");

          Object thread = call(localizerClass, classPathLocalizer,
              "runInThread");
          do {
            wait(WAIT_TIME_MILLIS);
          } while ((Boolean) call(thread.getClass(), thread, "isAlive"));

          for (URL url : (List<URL>) call(thread.getClass(), thread, "getUrls")) {
            addURL(url);
          }
        } catch (Throwable throwable) {
          Throwable cause = throwable.getCause() != null ? throwable.getCause()
              : throwable;
          logError("Failed to localize classed from hadoop: ", cause);
          throw new ClassNotFoundException(throwable.getMessage(), cause);
        }

        return super.findClass(name);
      } else {
        throw cne;
      }
    }
  }

  private void initLocalizer() throws ClassNotFoundException,
      InstantiationException, IllegalAccessException,
      InvocationTargetException, NoSuchMethodException {
    if (localizerClass == null) {
      localizerClass = loadClass("org.apache.hadoop.hbase.util.ClassPathLocalizer");
      classPathLocalizer = localizerClass.getConstructor((Class<?>[]) null)
          .newInstance((Object[]) null);
      call(localizerClass, classPathLocalizer, "init");
    }
  }

  private static boolean callIsATriggeringClass(Class<?> localizerClass,
      Object o, String name) throws NoSuchMethodException,
      IllegalAccessException, InvocationTargetException {
    Method isATriggeringClassMethod = localizerClass.getMethod(
        "isATriggeringClass", String.class);
    return (Boolean) isATriggeringClassMethod.invoke(o, name);
  }
  
  private static Object call(Class<?> clz, Object obj, String methodName)
      throws SecurityException, NoSuchMethodException,
      IllegalArgumentException, IllegalAccessException,
      InvocationTargetException {
    Method method = clz.getMethod(methodName);
    return method.invoke(obj);
  }

  public static void log(String message) {
    if (verbose) {
      System.out.printf("%s\n", message);
    }
  }

  public static void logError(String message, Throwable throwable) {
    if (verbose) {
      System.err.printf("%s: %s\n", message, throwable);
      throwable.printStackTrace();
    }
  }
}
