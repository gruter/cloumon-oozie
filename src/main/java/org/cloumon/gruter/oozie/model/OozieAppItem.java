package org.cloumon.gruter.oozie.model;

import java.util.HashMap;
import java.util.Map;

import org.jdom.input.DOMBuilder;
import org.jdom.output.Format;
import org.jdom.output.XMLOutputter;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class OozieAppItem {
	private String name;
	private String itemType;

	private Map<String, Object> itemProps;
	
	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getItemType() {
		return itemType;
	}

	public void setItemType(String itemType) {
		this.itemType = itemType;
	}

	public void setItemProps(Map<String, Object> itemProps) {
		this.itemProps = itemProps;
	}
	
	public String toString() {
		String result = "<" + itemType + " name=\"" + name + "\">\n";
		for(Map.Entry<String, Object> entry: itemProps.entrySet()) {
			if(entry.getValue() instanceof Map) {
				result += "\t<configuration>\n";
				Map<String, String> map = (Map<String, String>)entry.getValue();
				for(Map.Entry<String, String> subEntry: map.entrySet()) {
					result += "\t\t" + subEntry.getKey() + "=" + subEntry.getValue() + "\n";
				}
				result += "\t</configuration>\n";
			} else {
				result += "\t" + entry.getKey() + "=" + entry.getValue() + "\n";
			}
		}
		result += "</" + itemType + ">";
		return result;
	}
	
	public static OozieAppItem makeItem(Element element) {
		OozieAppItem appItem = new OozieAppItem();
		appItem.setItemType(element.getTagName());
		appItem.setName(element.getAttribute("name"));
		
		Map<String, Object> itemProps = new HashMap<String, Object>();
		
    if("start".equals(element.getTagName())) {
    	appItem.setName("start");
    	itemProps.put("to", element.getAttribute("to"));
    } else if("end".equals(element.getTagName())) {
    } else if("kill".equals(element.getTagName())) {
    	itemProps = getKillProps(element.getChildNodes());
    } else if("fork".equals(element.getTagName())) {
    	itemProps = getForkProps(element.getChildNodes());
    } else if("join".equals(element.getTagName())) {
    	itemProps.put("to", element.getAttribute("to"));
    } else if("decision".equals(element.getTagName())) {
    	itemProps = getDecisionProps(element.getElementsByTagName("switch"));
    } else if("action".equals(element.getTagName())) {
    	NodeList childNodes = element.getChildNodes();
  		for (int i = 0; i < childNodes.getLength(); i++) {
				Node propNode = childNodes.item(i);
		    if (!(propNode instanceof Element)) {
		    	continue;
		    }
		    Element prop = (Element)propNode;
		    if("map-reduce".equals(prop.getTagName())) {
					appItem.setItemType(prop.getTagName());
		    	itemProps.putAll(getHadoopActionProps(prop.getChildNodes()));
		    } else if("hive".equals(prop.getTagName())) {
					appItem.setItemType(prop.getTagName());
		    	itemProps.putAll(getHadoopActionProps(prop.getChildNodes()));
		    } else if("pig".equals(prop.getTagName())) {
					appItem.setItemType(prop.getTagName());
		    	itemProps.putAll(getHadoopActionProps(prop.getChildNodes()));
		    } else if("java".equals(prop.getTagName())) {
					appItem.setItemType(prop.getTagName());
		    	itemProps.putAll(getHadoopActionProps(prop.getChildNodes()));
		    } else if("fs".equals(prop.getTagName())) {
					appItem.setItemType(prop.getTagName());
		    	itemProps.putAll(getHadoopActionProps(prop.getChildNodes()));
		    } else if("shell".equals(prop.getTagName())) {
					appItem.setItemType(prop.getTagName());
		    	itemProps.putAll(getHadoopActionProps(prop.getChildNodes()));
		    } else if("ssh".equals(prop.getTagName())) {
					appItem.setItemType(prop.getTagName());
		    	itemProps.putAll(getSshProps(prop.getChildNodes()));
		    } else if("ok".equals(prop.getTagName()) || "error".equals(prop.getTagName())) {
		    	itemProps.put(prop.getTagName(), prop.getAttribute("to"));
		    } else {
					appItem.setItemType("user-defined");
		    	itemProps.put("actionXml", getXml(prop));
		    }
  		}
    } else {
    }

    appItem.setItemProps(itemProps);
    
		return appItem;
	}

	private static String getXml(Element element) {
		org.jdom.output.XMLOutputter outputter = new XMLOutputter(Format.getRawFormat());
		org.jdom.input.DOMBuilder builder = new DOMBuilder();
		return outputter.outputString(builder.build(element));
	}

	private static Map<String, Object> getForkProps(NodeList childNodes) {
		Map<String, Object> forkProps = new HashMap<String, Object>();
		
		for (int i = 0; i < childNodes.getLength(); i++) {
			Node propNode = childNodes.item(i);
	    if (!(propNode instanceof Element)) {
	    	continue;
	    }
	    Element prop = (Element)propNode;
	    forkProps.put(prop.getAttribute("start"), "");
		}
		
		return forkProps;
	}
	
	private static Map<String, Object> getKillProps(NodeList childNodes) {
		Map<String, Object> killProps = new HashMap<String, Object>();
		
		for (int i = 0; i < childNodes.getLength(); i++) {
			Node propNode = childNodes.item(i);
	    if (!(propNode instanceof Element)) {
	    	continue;
	    }
	    Element prop = (Element)propNode;
	    killProps.put(prop.getTagName(), prop.getTextContent());
		}
		
		return killProps;
	}
	
	private static Map<String, Object> getDecisionProps(NodeList switchNodes) {
		Map<String, Object> decisionProps = new HashMap<String, Object>();
		
		if(switchNodes == null || switchNodes.getLength() == 0) {
			return decisionProps;
		}
		
		NodeList childNodes = switchNodes.item(0).getChildNodes();
		for (int i = 0; i < childNodes.getLength(); i++) {
			Node propNode = childNodes.item(i);
	    if (!(propNode instanceof Element)) {
	    	continue;
	    }
	    Element prop = (Element)propNode;
	    if("case".equals(prop.getTagName())) {
	    	decisionProps.put(prop.getAttribute("to"), prop.getTextContent());
	    } else if("default".equals(prop.getTagName())){
	    	decisionProps.put("default", "");
	    }
		}
		
		return decisionProps;
	}
	
	private static Map<String, Object> getSshProps(NodeList childNodes) {
		Map<String, Object> sshProps = new HashMap<String, Object>();
		
		for (int i = 0; i < childNodes.getLength(); i++) {
			Node propNode = childNodes.item(i);
	    if (!(propNode instanceof Element)) {
	    	continue;
	    }
	    Element prop = (Element)propNode;
	    if("host".equals(prop.getTagName())) {
	    	sshProps.put("host", prop.getTextContent());
	    } else if("command".equals(prop.getTagName())) {
	    	sshProps.put("command", prop.getTextContent());
	    } else if("args".equals(prop.getTagName())) {
    		String previousArgs = (String)sshProps.get("args");
    		String delim = "\n";
    		if(previousArgs == null) {
    			previousArgs = "";
    			delim = "";
    		}
    		sshProps.put("args", previousArgs + delim + "<args>" + prop.getTextContent() + "</args>");
	    } else if("capture-output".equals(prop.getTagName())) {
	    	sshProps.put("capture-output", true);
	    }
		}
		
		return sshProps;
	}
	
	private static Map<String, Object> getHadoopActionProps(NodeList childNodes) {
		Map<String, Object> hadoopActionProps = new HashMap<String, Object>();
		
		for (int i = 0; i < childNodes.getLength(); i++) {
			Node propNode = childNodes.item(i);
	    if (!(propNode instanceof Element)) {
	    	continue;
	    }
	    Element prop = (Element)propNode;
	    if("configuration".equals(prop.getTagName())) {
	    	Map<String, String> propMap = new HashMap<String, String>();
	    	NodeList confChilds = prop.getChildNodes();
	    	for(int j = 0; j < confChilds.getLength(); j++) {
	    		Node confNode = confChilds.item(j);
	  	    if (!(confNode instanceof Element)) {
	  	    	continue;
	  	    }
	  	    Element confElement = (Element)confNode;
	  	    if(!"property".equals(confElement.getTagName())) {
	  	    	continue;
	  	    }
	  	    
	  	    NodeList namePropNode = confElement.getElementsByTagName("name");
	  	    if(namePropNode.getLength() == 0) {
	  	    	continue;
	  	    }
	  	    NodeList valuePropNode = confElement.getElementsByTagName("value");
	  	    String value = "";
	  	    if(valuePropNode.getLength() > 0) {
	  	    	value = valuePropNode.item(0).getTextContent();
	  	    }
	  	    propMap.put(namePropNode.item(0).getTextContent(), value);
	    	}
    		hadoopActionProps.put("configuration", propMap);
	    } else if("prepare".equals(prop.getTagName())) {
	    	NodeList prepareChilds = prop.getChildNodes();
	    	String prepare = "";
	    	String delim = "";
	    	for(int j = 0; j < prepareChilds.getLength(); j++) {
	    		Node prepareNode = prepareChilds.item(j);
	  	    if (!(prepareNode instanceof Element)) {
	  	    	continue;
	  	    }
	  	    Element prepareElement = (Element)prepareNode;
	    		prepare += delim + "<" + prepareElement.getTagName() + " path=\"" + prepareElement.getAttribute("path") + "\"/>";
	    		delim = "\n";
	    	}
    		hadoopActionProps.put("prepare", prepare);
	    } else if("param".equals(prop.getTagName())) {
    		hadoopActionProps.put("param", getMultipleProps("param", hadoopActionProps, prop));
	    } else if("arg".equals(prop.getTagName())) {
    		hadoopActionProps.put("arg", getMultipleProps("arg", hadoopActionProps, prop));
	    } else if("argument".equals(prop.getTagName())) {
    		hadoopActionProps.put("argument", getMultipleProps("argument", hadoopActionProps, prop));
	    } else if("env-var".equals(prop.getTagName())) {
    		hadoopActionProps.put("env-var", getMultipleProps("env-var", hadoopActionProps, prop));
	    } else if("script".equals(prop.getTagName())) {
    		hadoopActionProps.put("script", prop.getTextContent());
	    } else if("main-class".equals(prop.getTagName())) {
    		hadoopActionProps.put("main-class", prop.getTextContent());
	    } else if("exec".equals(prop.getTagName())) {
    		hadoopActionProps.put("exec", prop.getTextContent());
	    } else if("capture-output".equals(prop.getTagName())) {
	    	hadoopActionProps.put("capture-output", true);
	    } else if("job-xml".equals(prop.getTagName()) ||
	    		"file".equals(prop.getTagName()) ||
	    		"archive".equals(prop.getTagName())) {
	    	String fileProp = getMultipleProps("files", hadoopActionProps, prop, true);
    		hadoopActionProps.put("files", fileProp);
	    } else {
	    	hadoopActionProps.put(prop.getTagName(), prop.getTextContent());
	    }
		}
		
		return hadoopActionProps;
	}

	private static String getMultipleProps(String key, Map<String, Object> props, Element element, boolean useElementTagName) {
		String previousParams = (String)props.get(key);
		String delim = "\n";
		if(previousParams == null) {
			previousParams = "";
			delim = "";
		}
		
		String tagName = key;
		if(useElementTagName) {
			tagName = element.getTagName();
		}
		return previousParams + delim + "<" + tagName + ">" + element.getTextContent() + "</" + tagName + ">";
	}
	
	private static String getMultipleProps(String key, Map<String, Object> props, Element element) {
		return getMultipleProps(key, props, element, false);
	}

	public Map<String, Object> getItemProps() {
		return itemProps;
	}
}
