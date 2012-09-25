/**
 * 
 */
package org.cloumon.gruter.common;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.converter.HttpMessageNotWritableException;
import org.springframework.http.converter.json.MappingJacksonHttpMessageConverter;
import org.springframework.http.server.ServletServerHttpResponse;
import org.springframework.stereotype.Controller;
import org.springframework.web.context.WebApplicationContext;

/**
 * @author kimjh
 *
 */
@Controller
public class BaseController{
	protected static final Logger logger = LoggerFactory.getLogger(BaseController.class);

	@Autowired
	private WebApplicationContext ctx;
	protected MappingJacksonHttpMessageConverter jsonConverter = new MappingJacksonHttpMessageConverter();

	protected  WebApplicationContext getCurrentContext() {
		return ctx;
	}

	protected void setJsonResponse(Object bean, HttpServletResponse response) throws HttpMessageNotWritableException, IOException{
		MediaType jsonMimeType = MediaType.APPLICATION_JSON;
		if (jsonConverter.canWrite(String.class, jsonMimeType)) {
			jsonConverter.write(bean, jsonMimeType, new ServletServerHttpResponse(response));
		}
	}

	protected Map<String, Object> createSuccessResponse(Object data) {
		return createSuccessResponse("", data);
	}

	protected Map<String, Object> createSuccessResponse(String msg,  Object data) {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("success", Boolean.TRUE);
		result.put("data", data);
		result.put("msg", msg);
		return result;
	}

	protected Map<String, Object> createFailureResponse(String msg, Throwable e) {
		logger.error(msg, e);
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("success", Boolean.FALSE);
		result.put("msg", msg);
		return result;
	}

	protected Map<String, Object> createSuccessResponse(String msg, Object data, Object metaData) {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("success", Boolean.TRUE);
		result.put("data", data);
		result.put("metaData", metaData);
		result.put("msg", msg);
		return result;
	}

	protected Map<String, Object> createRetryResponse(String msg, Object data, Object metaData) {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("success", Boolean.TRUE);
		result.put("data", data);
		result.put("retry", true);
		result.put("metaData", metaData);
		result.put("msg", msg);
		return result;
	}
}
