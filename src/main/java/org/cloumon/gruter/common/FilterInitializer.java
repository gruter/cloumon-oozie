package org.cloumon.gruter.common;

/**
 * Initialize a javax.servlet.Filter. 
 */
public abstract class FilterInitializer {
  /**
   * Initialize a Filter to a FilterContainer.
   * @param container The filter container
   */
  abstract void initFilter(FilterContainer container);
}