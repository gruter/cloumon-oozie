package org.cloumon.gruter.oozie.model;

import java.io.ByteArrayInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class OozieApp {
	public static final Log LOG = LogFactory.getLog(OozieApp.class);
	
	private String appName;
	private String xml;
	private String creator;
	private String description;
	private String appPath;
	private String positions;
	private List<OozieAppItem> items = new ArrayList<OozieAppItem>();
	
	public String getAppName() {
		return appName;
	}
	public void setAppName(String appName) {
		this.appName = appName;
	}
	public String getXml() {
		return xml;
	}
	public void setXml(String xml) {
		this.xml = xml;
	}
	public List<OozieAppItem> getItems() {
		return items;
	}
	public void setItems(List<OozieAppItem> items) {
		this.items = items;
	}
	public String getCreator() {
		return creator;
	}
	public void setCreator(String creator) {
		this.creator = creator;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public String getAppPath() {
		return appPath;
	}
	public void setAppPath(String appPath) {
		this.appPath = appPath;
	}
	public String getPositions() {
		return positions;
	}
	public void setPositions(String positions) {
		this.positions = positions;
	}

	public void parseXml() throws Exception {
		if(xml == null || xml.isEmpty()) {
			//throw new IOException("No xml info");
			return;
		}
		
		String xmlStr = xml;
		if(!xmlStr.startsWith("<?xml")) {
			xmlStr = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + xml;
		}
    DocumentBuilderFactory docBuilderFactory = DocumentBuilderFactory.newInstance();
    docBuilderFactory.setIgnoringComments(true);
    //docBuilderFactory.setNamespaceAware(true);
    /*
    try {
        docBuilderFactory.setXIncludeAware(true);
    } catch (UnsupportedOperationException e) {
      LOG.error("Failed to set setXIncludeAware(true) for parser " + docBuilderFactory + ":" + e, e);
    }
    */
    DocumentBuilder builder = docBuilderFactory.newDocumentBuilder();
    Document doc = builder.parse(new ByteArrayInputStream(xmlStr.getBytes()));
    Element root = doc.getDocumentElement();

    NodeList itemNodes = root.getChildNodes();
    for (int i = 0; i < itemNodes.getLength(); i++) {
      Node propNode = itemNodes.item(i);
      if (!(propNode instanceof Element)) {
      	continue;
      }
      Element prop = (Element)propNode;
 
      items.add(OozieAppItem.makeItem(prop));
    }
	}

	@Override
	public String toString() {
		return appName;
	}
	
	public static void main(String[] args) throws Exception {
		InputStream in = new FileInputStream("/Users/babokim/work/program/oozie-3.2.0-incubating/examples/apps/map-reduce/workflow.xml1");
		
		byte[] buf = new byte[1024 * 1024];
		
		int length = in.read(buf);
		
		OozieApp app = new OozieApp();
		app.setXml(new String(buf, 0, length));
		
		app.parseXml();
		
		System.out.println(app.toString());
	}
}
