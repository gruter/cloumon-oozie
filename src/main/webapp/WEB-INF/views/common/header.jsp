<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="taglibs.jsp"%>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" /> 
<title>Cloumon-Oozie</title>
<script type="text/javascript">
APPLICATION_CONTEXT = '${ctx}';
if(APPLICATION_CONTEXT != '/') APPLICATION_CONTEXT += '/';
</script>

<link rel="stylesheet" type="text/css" href="${ctx}/resources/css/workflow/item.css"/>
<link rel="stylesheet" type="text/css" href="${ctx}/resources/css/workflow/tab.css"/>
<link rel="stylesheet" type="text/css" href="${ctx}/resources/css/workflow/flow.css"/>
<link rel="stylesheet" type="text/css" href="${ctx}/resources/js/lib/jqgrid/themes/ui.jqgrid.css" />
<link rel="stylesheet" type="text/css" href="${ctx}/resources/js/lib/jqgrid/themes/ui.multiselect.css" />
<link rel="stylesheet" type="text/css" href="${ctx}/resources/js/lib/jqgrid/themes/redmond/jquery-ui-1.8.23.custom.css" />

<script type="text/javascript" src="${ctx}/resources/js/lib/jquery-1.7.2.min.js"></script>
<script type="text/javascript" src="${ctx}/resources/js/lib/jquery-ui-1.8.21.custom.min.js"></script>
<script type="text/javascript" src="${ctx}/resources/js/lib/jquery.jsPlumb-1.3.10-all.js"></script>
<script type="text/javascript" src="${ctx}/resources/js/lib/jquery.easytabs.js"></script>
<script type="text/javascript" src="${ctx}/resources/js/lib/jquery.hashchange.min.js"></script>

<script type="text/javascript" src="${ctx}/resources/js/lib/jqgrid/jquery.jqGrid.src.js"></script>
<script type="text/javascript" src="${ctx}/resources/js/lib/jqgrid/i18n/grid.locale-en.js"></script>

<script type="text/javascript" src="${ctx}/resources/js/workflow/hashmap.js"></script>
<script type="text/javascript" src="${ctx}/resources/js/workflow/workflow-item.js"></script>
<script type="text/javascript" src="${ctx}/resources/js/workflow/common.js"></script>
