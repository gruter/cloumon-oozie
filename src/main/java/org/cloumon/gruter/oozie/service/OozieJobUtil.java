package org.cloumon.gruter.oozie.service;


import java.io.IOException;
import java.io.OutputStream;
import java.util.Enumeration;
import java.util.Properties;

import javax.servlet.http.HttpServletResponse;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.apache.hadoop.conf.Configuration;
import org.apache.oozie.DagEngine;
import org.apache.oozie.DagEngineException;
import org.apache.oozie.ErrorCode;
import org.apache.oozie.client.OozieClient;
import org.apache.oozie.client.rest.JsonTags;
import org.apache.oozie.service.DagEngineService;
import org.apache.oozie.service.Services;
import org.apache.oozie.servlet.XServletException;
import org.json.simple.JSONObject;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

public class OozieJobUtil {
	Services services;
	
	public OozieJobUtil(Services services) {
		this.services = services;
	}
	
	void validateAppPath(String wfPath, String coordPath, String bundlePath) throws XServletException {
    int n = 0;
    
    if (wfPath != null) {
        n ++;
    }
    
    if (coordPath != null) {
        n ++;
    }
    
    if (bundlePath != null) {
        n ++;
    }
    
    if (n != 1) {
        throw new XServletException(HttpServletResponse.SC_BAD_REQUEST, ErrorCode.E0302);
    }
	}
	
  public void writeToXml(Properties props, OutputStream out) throws IOException {
    try {
        Document doc = DocumentBuilderFactory.newInstance().newDocumentBuilder().newDocument();
        Element conf = doc.createElement("configuration");
        doc.appendChild(conf);
        conf.appendChild(doc.createTextNode("\n"));
        for (Enumeration e = props.keys(); e.hasMoreElements();) {
            String name = (String) e.nextElement();
            Object object = props.get(name);
            String value;
            if (object instanceof String) {
                value = (String) object;
            }
            else {
                continue;
            }
            Element propNode = doc.createElement("property");
            conf.appendChild(propNode);

            Element nameNode = doc.createElement("name");
            nameNode.appendChild(doc.createTextNode(name.trim()));
            propNode.appendChild(nameNode);

            Element valueNode = doc.createElement("value");
            valueNode.appendChild(doc.createTextNode(value.trim()));
            propNode.appendChild(valueNode);

            conf.appendChild(doc.createTextNode("\n"));
        }

        DOMSource source = new DOMSource(doc);
        StreamResult result = new StreamResult(out);
        TransformerFactory transFactory = TransformerFactory.newInstance();
        Transformer transformer = transFactory.newTransformer();
        transformer.transform(source, result);
    }
    catch (Exception e) {
        throw new IOException(e);
    }
  }
  
  public String submitJob(Configuration conf) throws XServletException,
          IOException {
    try {
    	String user = conf.get(OozieClient.USER_NAME);
    	DagEngineService service = services.get(DagEngineService.class);
    	
    	DagEngine dagEngine = service.getDagEngine(user, "?");

    	String id = dagEngine.submitJob(conf, true);
      return id;
    }
    catch (DagEngineException ex) {
        throw new XServletException(HttpServletResponse.SC_BAD_REQUEST, ex);
    }
  }

  /**
   * v1 service implementation to get a JSONObject representation of a job from its external ID
   */
  protected JSONObject getJobIdForExternalId(String jobType, String externalId) throws XServletException,
          IOException {
      JSONObject json = null;
      /*
       * Configuration conf = new XConfiguration(); String wfPath =
       * conf.get(OozieClient.APP_PATH); String coordPath =
       * conf.get(OozieClient.COORDINATOR_APP_PATH);
       *
       * ServletUtilities.ValidateAppPath(wfPath, coordPath);
       */
      jobType = (jobType != null) ? jobType : "wf";
      if (jobType.contains("wf")) {
          json = getWorkflowJobIdForExternalId(jobType, externalId);
      }
      else {
          json = getCoordinatorJobIdForExternalId(jobType, externalId);
      }
      return json;
  }

  /**
   * v1 service implementation to get a list of workflows, coordinators, or bundles, with filtering or interested
   * windows embedded in the request object
   */
//  protected JSONObject getJobs(String jobType) throws XServletException, IOException {
//      JSONObject json = null;
//      jobType = (jobType != null) ? jobType : "wf";
//
//      if (jobType.contains("wf")) {
//          json = getWorkflowJobs(jobType);
//      }
//      else if (jobType.contains("coord")) {
//          json = getCoordinatorJobs(jobType);
//      }
//      else if (jobType.contains("bundle")) {
//          json = getBundleJobs();
//      }
//      return json;
//  }

  /**
   * v1 service implementation to get a JSONObject representation of a job from its external ID
   */
  @SuppressWarnings("unchecked")
  private JSONObject getWorkflowJobIdForExternalId(String jobType, String externalId)
          throws XServletException {
      JSONObject json = new JSONObject();
      try {
          DagEngine dagEngine = Services.get().get(DagEngineService.class).getSystemDagEngine();
          String jobId = dagEngine.getJobIdForExternalId(externalId);
          json.put(JsonTags.JOB_ID, jobId);
      }
      catch (DagEngineException ex) {
          throw new XServletException(HttpServletResponse.SC_BAD_REQUEST, ex);
      }
      return json;
  }

  /**
   * v1 service implementation to get a JSONObject representation of a job from its external ID
   */
  private JSONObject getCoordinatorJobIdForExternalId(String jobType, String externalId)
          throws XServletException {
      JSONObject json = new JSONObject();
      return json;
  }

//  private JSONObject getWorkflowJobs() throws XServletException {
//      JSONObject json = new JSONObject();
//      try {
//          String filter = request.getParameter(RestConstants.JOBS_FILTER_PARAM);
//          String startStr = request.getParameter(RestConstants.OFFSET_PARAM);
//          String lenStr = request.getParameter(RestConstants.LEN_PARAM);
//          int start = (startStr != null) ? Integer.parseInt(startStr) : 1;
//          start = (start < 1) ? 1 : start;
//          int len = (lenStr != null) ? Integer.parseInt(lenStr) : 50;
//          len = (len < 1) ? 50 : len;
//          DagEngine dagEngine = Services.get().get(DagEngineService.class).getDagEngine(getUser(request),
//                  getAuthToken(request));
//          WorkflowsInfo jobs = dagEngine.getJobs(filter, start, len);
//          List<WorkflowJobBean> jsonWorkflows = jobs.getWorkflows();
//          json.put(JsonTags.WORKFLOWS_JOBS, WorkflowJobBean.toJSONArray(jsonWorkflows));
//          json.put(JsonTags.WORKFLOWS_TOTAL, jobs.getTotal());
//          json.put(JsonTags.WORKFLOWS_OFFSET, jobs.getStart());
//          json.put(JsonTags.WORKFLOWS_LEN, jobs.getLen());
//
//      }
//      catch (DagEngineException ex) {
//          throw new XServletException(HttpServletResponse.SC_BAD_REQUEST, ex);
//      }
//
//      return json;
//  }

  /**
   * v1 service implementation to get a list of workflows, with filtering or interested windows embedded in the
   * request object
   */
//  @SuppressWarnings("unchecked")
//  private JSONObject getCoordinatorJobs(HttpServletRequest request) throws XServletException {
//      JSONObject json = new JSONObject();
//      try {
//          String filter = request.getParameter(RestConstants.JOBS_FILTER_PARAM);
//          String startStr = request.getParameter(RestConstants.OFFSET_PARAM);
//          String lenStr = request.getParameter(RestConstants.LEN_PARAM);
//          int start = (startStr != null) ? Integer.parseInt(startStr) : 1;
//          start = (start < 1) ? 1 : start;
//          int len = (lenStr != null) ? Integer.parseInt(lenStr) : 50;
//          len = (len < 1) ? 50 : len;
//          CoordinatorEngine coordEngine = Services.get().get(CoordinatorEngineService.class).getCoordinatorEngine(
//                  getUser(request), getAuthToken(request));
//          CoordinatorJobInfo jobs = coordEngine.getCoordJobs(filter, start, len);
//          List<CoordinatorJobBean> jsonJobs = jobs.getCoordJobs();
//          json.put(JsonTags.COORDINATOR_JOBS, CoordinatorJobBean.toJSONArray(jsonJobs));
//          json.put(JsonTags.COORD_JOB_TOTAL, jobs.getTotal());
//          json.put(JsonTags.COORD_JOB_OFFSET, jobs.getStart());
//          json.put(JsonTags.COORD_JOB_LEN, jobs.getLen());
//
//      }
//      catch (CoordinatorEngineException ex) {
//          throw new XServletException(HttpServletResponse.SC_BAD_REQUEST, ex);
//      }
//      return json;
//  }

  @SuppressWarnings("unchecked")
//  private JSONObject getBundleJobs(HttpServletRequest request) throws XServletException {
//      JSONObject json = new JSONObject();
//      try {
//          String filter = request.getParameter(RestConstants.JOBS_FILTER_PARAM);
//          String startStr = request.getParameter(RestConstants.OFFSET_PARAM);
//          String lenStr = request.getParameter(RestConstants.LEN_PARAM);
//          int start = (startStr != null) ? Integer.parseInt(startStr) : 1;
//          start = (start < 1) ? 1 : start;
//          int len = (lenStr != null) ? Integer.parseInt(lenStr) : 50;
//          len = (len < 1) ? 50 : len;
//
//          BundleEngine bundleEngine = Services.get().get(BundleEngineService.class).getBundleEngine(getUser(request),
//                  getAuthToken(request));
//          BundleJobInfo jobs = bundleEngine.getBundleJobs(filter, start, len);
//          List<BundleJobBean> jsonJobs = jobs.getBundleJobs();
//
//          json.put(JsonTags.BUNDLE_JOBS, BundleJobBean.toJSONArray(jsonJobs));
//          json.put(JsonTags.BUNDLE_JOB_TOTAL, jobs.getTotal());
//          json.put(JsonTags.BUNDLE_JOB_OFFSET, jobs.getStart());
//          json.put(JsonTags.BUNDLE_JOB_LEN, jobs.getLen());
//
//      }
//      catch (BundleEngineException ex) {
//          throw new XServletException(HttpServletResponse.SC_BAD_REQUEST, ex);
//      }
//      return json;
//  }

  /**
   * service implementation to submit a job
   */
  private String submitHttpJob(String jobType, Configuration conf)
          throws XServletException {
      try {
          DagEngine dagEngine = services.get(DagEngineService.class).getSystemDagEngine();
          String id = dagEngine.submitHttpJob(conf, jobType);
          return id;
      }
      catch (DagEngineException ex) {
          throw new XServletException(HttpServletResponse.SC_BAD_REQUEST, ex);
      }
  }
}
