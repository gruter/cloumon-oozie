package org.cloumon.gruter.common;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import org.apache.commons.httpclient.MultiThreadedHttpConnectionManager;

public class CloumonContextListener implements ServletContextListener {
//	private static final Logger LOG = LoggerFactory.getLogger(IdbcContextListener.class);

	@Override
	public void contextDestroyed(ServletContextEvent event) {
		MultiThreadedHttpConnectionManager.shutdownAll();
	}

	@Override
	public void contextInitialized(ServletContextEvent arg0) {
	}
}