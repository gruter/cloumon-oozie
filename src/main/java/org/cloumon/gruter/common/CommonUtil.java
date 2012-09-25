package org.cloumon.gruter.common;

import java.text.DecimalFormat;
import java.util.Collection;

public class CommonUtil {
  static DecimalFormat df = new DecimalFormat("###,###,###.#");
  
  public static String listToStr(Collection<? extends Object> collection, String delim) {
    StringBuilder sb = new StringBuilder();
    
    String tmpDelim = "";
    for(Object eachObj: collection) {
      sb.append(tmpDelim).append(eachObj);
      tmpDelim = delim;
    }
    
    return sb.toString();
  }
  
  public static String getFileLengthText(long length) {
    if(length < 1024) {
      return df.format(length) + " Bytes";
    } else if(length >= 1024 && length < 1024 * 1024) {
      return df.format(((double)length/1024.0)) + " KB";
    } else if(length >= 1024 * 1024 && length < 1024 * 1024 * 1024) {
      return df.format(((double)length/(1024.0 * 1024.0))) + " MB";
    } else {
      return df.format(((double)length/(1024.0 * 1024.0 * 1024.0))) + " GB";
    }
  }
}
