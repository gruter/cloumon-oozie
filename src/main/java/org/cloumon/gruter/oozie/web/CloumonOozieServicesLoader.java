package org.cloumon.gruter.oozie.web;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import org.apache.oozie.service.Services;

public class CloumonOozieServicesLoader implements ServletContextListener {
  public static Services services;

  /**
   * Initialize Oozie services.
   *
   * @param event context event.
   */
  public void contextInitialized(ServletContextEvent event) {
      try {
          services = new Services();
          services.init();
      }
      catch (Throwable ex) {
          System.out.println();
          System.out.println("ERROR: Oozie could not be started");
          System.out.println();
          System.out.println("REASON: " + ex.toString());
          System.out.println();
          System.out.println("Stacktrace:");
          System.out.println("-----------------------------------------------------------------");
          ex.printStackTrace(System.out);
          System.out.println("-----------------------------------------------------------------");
          System.out.println();
          System.exit(1);
      }
  }

  /**
   * Destroy Oozie services.
   *
   * @param event context event.
   */
  public void contextDestroyed(ServletContextEvent event) {
      services.destroy();
  }

}
