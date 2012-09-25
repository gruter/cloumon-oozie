package org.cloumon.gruter.common;

import java.util.Map;

/**
 * A container class for javax.servlet.Filter. 
 */
public interface FilterContainer {
  /**
   * Add a filter to the container.
   * @param name Filter name
   * @param classname Filter class name
   * @param parameters a map from parameter names to initial values
   */
  void addFilter(String name, String classname, Map<String, String> parameters);
  /**
   * Add a global filter to the container.
   * @param name filter name
   * @param classname filter class name
   * @param parameters a map from parameter names to initial values
   */
  void addGlobalFilter(String name, String classname, Map<String, String> parameters);
}
