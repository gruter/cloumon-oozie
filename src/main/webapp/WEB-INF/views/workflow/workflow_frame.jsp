<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" style="overflow: hidden;">
<head>
<%@ include file="../common/meta.jsp"%>
<%@ include file="./cloumon_header.jsp"%>
<%@ include file="./header.jsp"%>

<style type="text/css">
html, body {
	width:		100%;
	height:		100%;
	padding:	0;
	margin:		0;
	overflow:	hidden !important;
}
#layout-container {
	width:	100%;
	height:	100%;
}
#appDesign {
	position: relative;
	font-size:13px;
}

#propertyDiv {
	font-family: verdana;
	border: 1px solid #AAAAAA;
	background: #ffffff;
	margin-left: 3px;
	padding-bottom: 3px;
	border-radius: 4px;
}

#propertyDiv div {
	font-size:11px; 
	font-family: verdana; 
	margin-left: 5px; 
	margin-top: 10px;
}

.itemMenu {
	cursor:pointer;
	font-size: 11px;
	padding: 5px 5px 5px 5px;
}

</style>

<%
	String appName = request.getParameter("editAppName");
%>
<script><!--

//http://krikus.com/js/splitter/
//http://matthewjamestaylor.com/blog/equal-height-columns-cross-browser-css-no-hacks

//var propertyTableLastSelected;	
var defaultJobProperties;	//default job properties
var defaultHiveProperties;	//default hive job properties
var libSelectDialogParams;	//use when libSelectDialog closed 
var libFileClassInfo;		//class selection dialog

var oozieClusterInfo;	//jobtracker, namenode list
var actionPropertyReturnPrefix;	//use when actionPropertyDialog closed 

var addLibDialogCallback;	//callback funcion after add lib dialog

var editAppName = "<%=appName%>";

var designSaved = false;

function resizeLayout(event, container) {
	$("#appListTable").setGridWidth($("#westPane").width() - 5);
	$("#appListTable").setGridHeight($("#westPane").height() - 86);

	$("#appDesign").height($('#centerPane').height() - 35);

	$("#appLibListTable").setGridWidth($("#eastPane").width() - 10);
	$("#appLibListTable").setGridHeight($("#eastPane").height() - 158);

	$("#appXml").css( {width: ($("#eastPane").width() - 20) + 'px', height: ($("#eastPane").height() - 191) + 'px'} );
	$("#propertyXml").css( {width: ($("#eastPane").width() - 20) + 'px', height: ($("#eastPane").height() - 145) + 'px'} );
}

$(document).ready(function() {
	document.onselectstart = function () { return false; };		
	
	jsPlumbWorkflow.init();

	$("#workflow_entries").accordion({
		autoHeight: false
	});

	$("#tab-container").tabs({
		select: function(event, ui) {
			resizeLayout('tab_selection', $("#westPane"));
    	}		
	});

	$("#propertyTabContainer").tabs({
		select: function(event, ui) {
        	if(ui.index == 1) {
        		var appName = $('#appName').val();
					
        		if(appName == null || appName == "") {
            		appName = "";
        		}
        		refreshLibFileTable(appName);
        	}
        	resizeLayout('tab_selection', $("#eastPane"));
		}	
	});

	$("#map-reduceDialog-tab").tabs();
	
	$("#setting").button( { icons: { primary: "ui-icon-gear" } } );

	getOozieClusterInfo();
	
	getDefaultJobProperties();

	getDefaultHiveProperties();

	$('#configDialog').dialog({ 
		width: 700, height: 600, modal: true, autoOpen: false,
        buttons: [{
        	text: "Ok",
        	click:  function() {
				var itemId = $('#configItemId').val();
    			var item = screenItems.get(itemId);
    			item.setSubitemXmls();
    			item.getConfigFromDialogAndSet();
            	$(this).dialog("close");
            	item.showConfigXml();
        	}
        }, {
        	text: "Cancel",
            click: function() {
        		var itemId = $('#configItemId').val();
				var item = screenItems.get(itemId);
				item.tempSubitemXmls.clear();
            	$(this).dialog("close");
            }
		}]
	});

	$('#configDetailDialog').dialog({ 
		width: 500, height: 400, modal: true, autoOpen: false,
        buttons: [{
        	text: "Ok",
        	click:  function() {
        		var returnDivId = $('#subitemReturnDivId').val();
        		var xml = $('#subitemXml').val();
				var div = "<div class='config_item'><div style='float:left; width: 100px'>&nbsp;</div><div id='" + returnDivId + "_xml' style='float:left;'></div><div style='clear:both'></div></div>";
				$(div).insertAfter($('#' + returnDivId));

	    		$('#' + returnDivId + '_xml').text(xml);
            	$(this).dialog("close");

            	var itemId = $('#configItemId').val();
            	var subitemIndex = $('#subitemIndex').val();
    			var item = screenItems.get(itemId);
    			item.setTempSubItemXml(subitemIndex, xml);
        	}
        }, {
        	text: "Cancel",
            click: function() {
            	$(this).dialog("close");
            }
		}]
	});

	$('#decisionConfigDialog').dialog({ 
		width: 700, height: 500, modal: true, autoOpen: false,
        buttons: [{
        	text: "Ok",
        	click:  function() {
				var itemId = $('#decisionConfigItemId').val();
    			var item = screenItems.get(itemId);
    			var condition = $('#decisionConfigCondition').val();
    			if(condition == "") {
        			alert('No condition');
        			return;
    			}
				var decisionCase = $("#decisionCase option:selected").val();
				if(decisionCase == undefined) {
					alert('select case or default');
					return;
				} 

    			item.addDecision($('#decisionTargetItemId').val(), decisionCase, condition);
            	$(this).dialog("close");
            	item.showConfigXml();
        	}
        }, {
        	text: "Cancel",
            click: function() {
            	$(this).dialog("close");
            }
		}]
	});

	$('#appLibUploadForm').ajaxForm({
        beforeSubmit: function() {
			var appName = $("#libAppName").val();
			if(appName == null || appName == "") {
				alert("No app name");
				return;
			}
        	$('#libUploadMessage').html('Uploading...');
    	},
    	success: function(data) {
    		$("#appLibDialog").dialog("close");
    		var appName = $("#libAppName").val();
    		if(addLibDialogCallback == null) {
	    		refreshLibFileTable(appName);
	
	    		if($("#jobLibClassListDialog").dialog('isOpen') == true) {
	    			showLibClassDialog();
	    		}
    		} else {
    			addLibDialogCallback();
    		}
    	}
	});
	
	$('#appLibDialog').dialog({
		width: 600, height: 200, modal: true, autoOpen: false,
        buttons: [{
        	text: "Save",
        	click:  function() {
		        $("#appLibUploadForm").submit();
        	}
        }, {
        	text: "Cancel",
            click: function() {
            	$(this).dialog("close");
            }
		}]
	});


	$('#endDialog').dialog({
		width: 400, height: 130, modal: true, autoOpen: false,
        buttons: [{
        	text: "Ok",
        	click:  function() {
        		var itemId = $("#currentConfigItemId").val();
        	
        		var item = designManager.getItem(itemId);
        		if(item == null) {
        			alert("No selected item:" + itemId);
        			return;
        		}
        		if(!item.setName($("#endDialog_name").val())) {
					return;
				}
        		
	        	$("#propertyXml").val(item.getXml());
        	
        		$(this).dialog("close");
        	}
        }, {
        	text: "Cancel",
            click: function() {
            	$(this).dialog("close");
            }
		}]
	});

	$('#killDialog').dialog({
		width: 470, height: 170, modal: true, autoOpen: false,
        buttons: [{
        	text: "Ok",
        	click:  function() {
        		var itemId = $("#currentConfigItemId").val();
        	
        		var item = designManager.getItem(itemId);
        		if(item == null) {
        			alert("No selected item:" + itemId);
        			return;
        		}
        		if(!item.setName($("#killDialog_name").val())) {
					return;
				}
        		item.message = $("#killDialog_message").val();
        		
	        	$("#propertyXml").val(item.getXml());
        	
        		$(this).dialog("close");
        	}
        }, {
        	text: "Cancel",
            click: function() {
            	$(this).dialog("close");
            }
		}]
	});

	$('#decisionDialog').dialog({
		width: 650, height: 400, modal: true, autoOpen: false,
        buttons: [{
        	text: "Ok",
        	click:  function() {
        		if(setDecisionInfo()) {
                	$(this).dialog("close");
        		}	
        	}
        }, {
        	text: "Cancel",
            click: function() {
            	$(this).dialog("close");
            }
		}]
	});

	$('#decisionConditionDialog').dialog({
		width: 600, height: 130, modal: true, autoOpen: false,
		open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); },
        buttons: [{
        	text: "Ok",
        	click:  function() {
        		if(setDecisionCondition()) {
               		$(this).dialog("close");
        		}
        	}
        }, {
        	text: "Delete Connection",
            click: function() {
            	cancelDecisionConnection();
            	$(this).dialog("close");
            }
		}]	
	});

	$('#forkDialog').dialog({
		width: 470, height: 130, modal: true, autoOpen: false,
        buttons: [{
        	text: "Ok",
        	click:  function() {
        		var itemId = $("#currentConfigItemId").val();
        	
        		var item = designManager.getItem(itemId);
        		if(item == null) {
        			alert("No selected item:" + itemId);
        			return;
        		}
     	   		if(!item.setName($("#forkDialog_name").val())) {
					return;
				}
        		
	        	$("#propertyXml").val(item.getXml());
        	
        		$(this).dialog("close");
        	}
        }, {
        	text: "Cancel",
            click: function() {
            	$(this).dialog("close");
            }
		}]
	});

	$('#joinDialog').dialog({
		width: 470, height: 130, modal: true, autoOpen: false,
        buttons: [{
        	text: "Ok",
        	click:  function() {
        		var itemId = $("#currentConfigItemId").val();
        	
        		var item = designManager.getItem(itemId);
        		if(item == null) {
        			alert("No selected item:" + itemId);
        			return;
        		}
        		if(!item.setName($("#joinDialog_name").val())) {
					return false;
				}
        		
	        	$("#propertyXml").val(item.getXml());
        	
        		$(this).dialog("close");
        	}
        }, {
        	text: "Cancel",
            click: function() {
            	$(this).dialog("close");
            }
		}]
	});

	$('#queryActionDialog').dialog({
		width: 800, height: 650, modal: true, autoOpen: false,
        buttons: [{
        	text: "Ok",
        	click:  function() {
        		if(setQueryActionInfo()) {
                	$(this).dialog("close");
        		}	
        	}
        }, {
        	text: "Cancel",
            click: function() {
            	$(this).dialog("close");
            }
		}]
	});

	$("#actionPropertyDialog").dialog({
		width: 600, height: 400, modal: true, autoOpen: false,
        buttons: [{
        	text: "Ok",
        	click:  function() {
        		var rowid = $("#actionDefaultPropertyTable").jqGrid("getGridParam", "selrow");
            	if(rowid != null && rowid != "") {
        			$("#" + actionPropertyReturnPrefix + "DialogPropertyName").val($("#actionDefaultPropertyTable").jqGrid('getCell', rowid, 'name'));
        			$("#" + actionPropertyReturnPrefix + "DialogPropertyValue").val($("#actionDefaultPropertyTable").jqGrid('getCell', rowid, 'value'));
            	}
            	$(this).dialog("close");
        	}
        }, {
        	text: "Cancel",
            click: function() {
            	$(this).dialog("close");
            }
		}]
	});

	$("#hiveQueryDialog").dialog({
		width: 700, height: 500, modal: true, autoOpen: false,
        buttons: [{
        	text: "Ok",
        	click:  function() {
        		var query = $("#hiveQueryDialog_query").val();
            	if(query != null && query != "") {
                	$("#queryActionDialog_query").val(query);
            	}
            	$(this).dialog("close");
        	}
        }, {
        	text: "Cancel",
            click: function() {
            	$(this).dialog("close");
            }
		}]		
	});

	$("#appLibSelectDialog").dialog({
		width: 700, height: 500, modal: true, autoOpen: false,
        buttons: [{
        	text: "Ok",
        	click:  function() {
	    		var fileName = $("#appLibSelectTable").jqGrid("getGridParam", "selrow");
	        	if(fileName != null && fileName != "") {
	    			if(libSelectDialogParams != null) {
	    				for(var i = 0; i < libSelectDialogParams.length; i++) {
	    					var value = "";
							if(libSelectDialogParams[i][0] == "query") {
								value = $("#appLibSelectDialog_query").val();
							} else {
	    						value = $("#appLibSelectTable").jqGrid('getCell', fileName, libSelectDialogParams[i][0]);
							}
	    		    		$("#" + libSelectDialogParams[i][1]).val(value);	
	    				}
	    			}
	        	}
            	$(this).dialog("close");
        	}
        }, {
        	text: "Cancel",
            click: function() {
            	$(this).dialog("close");
            }
		}]		
	});
	
	$('#map-reduceDialog').dialog({
		width: 800, height: 650, modal: true, autoOpen: false,
        buttons: [{
        	text: "Ok",
        	click:  function() {
        		if(setMapReduceActionInfo()) {
                	$(this).dialog("close");
        		}	
        	}
        }, {
        	text: "Cancel",
            click: function() {
            	$(this).dialog("close");
            }
		}]
	});

	$('#sshDialog').dialog({
		width: 550, height: 350, modal: true, autoOpen: false,
        buttons: [{
        	text: "Ok",
        	click:  function() {
        		if(setSshActionInfo()) {
                	$(this).dialog("close");
        		}	
        	}
        }, {
        	text: "Cancel",
            click: function() {
            	$(this).dialog("close");
            }
		}]
	});

	$('#javaDialog').dialog({
		width: 800, height: 650, modal: true, autoOpen: false,
        buttons: [{
        	text: "Ok",
        	click:  function() {
        		if(setJavaActionInfo()) {
                	$(this).dialog("close");
        		}	
        	}
        }, {
        	text: "Cancel",
            click: function() {
            	$(this).dialog("close");
            }
		}]
	});

	$('#fsDialog').dialog({
		width: 600, height: 500, modal: true, autoOpen: false,
        buttons: [{
        	text: "Ok",
        	click:  function() {
        		if(setFsActionInfo()) {
                	$(this).dialog("close");
        		}	
        	}
        }, {
        	text: "Cancel",
            click: function() {
            	$(this).dialog("close");
            }
		}]
	});

	$('#shellDialog').dialog({
		width: 800, height: 650, modal: true, autoOpen: false,
        buttons: [{
        	text: "Ok",
        	click:  function() {
        		if(setShellActionInfo()) {
                	$(this).dialog("close");
        		}	
        	}
        }, {
        	text: "Cancel",
            click: function() {
            	$(this).dialog("close");
            }
		}]
	});

	$('#userDefineDialog').dialog({
		width: 800, height: 500, modal: true, autoOpen: false,
        buttons: [{
        	text: "Ok",
        	click:  function() {
        		if(setUserDefinedActionInfo()) {
                	$(this).dialog("close");
        		}	
        	}
        }, {
        	text: "Cancel",
            click: function() {
            	$(this).dialog("close");
            }
		}]
	});
	
	
	$("#jobPropertyDialog").dialog({
		width: 600, height: 400, modal: true, autoOpen: false,
        buttons: [{
        	text: "Ok",
        	click:  function() {
        		var id = $("#jobDefaultPropertyTable").jqGrid("getGridParam", "selrow");
            	if(id != null && id != "") {
                	$("#saveMapReducePropertyName").val($("#jobDefaultPropertyTable").jqGrid('getCell', id, 'name'));
            	}
            	$(this).dialog("close");
        	}
        }, {
        	text: "Cancel",
            click: function() {
            	$(this).dialog("close");
            }
		}]
	});

	$("#jobLibClassListDialog").dialog({
		width: 800, height: 500, modal: true, autoOpen: false,
        buttons: [{
        	text: "Ok",
        	click:  function() {
    			var className = $("#jobLibClassListTable").jqGrid("getGridParam", "selrow");
            	if(className != null && className != "" && className != "undefined") {
                	$("#" + $("#jobLibClassListDialog_returnId").val()).val(className);
            	}
            	$(this).dialog("close");
        	}
        }, {
        	text: "Cancel",
            click: function() {
            	$(this).dialog("close");
            }
		}]		
	});

	$("#newAppDialog").dialog({
		width: 400, height: 140, modal: true, autoOpen: false,
        buttons: [{
        	text: "Ok",
        	click:  function() {
				addNewApp();
        	}
        }, {
        	text: "Cancel",
            click: function() {
            	$(this).dialog("close");
            }
		}]	
	});

	$("#elFunctionDialog").dialog({
		width: 830, height: 650, modal: true, autoOpen: false,
        buttons: [{
        	text: "Ok",
        	click:  function() {
        		var functionName = $("#elFunctionTable").jqGrid('getGridParam', 'selrow');
        		if(functionName != null) {
        			$("#" + $("#elFunctionResultField").val()).val(functionName);
        		}
	    		$(this).dialog("close");
        	}
        }, {
        	text: "Cancel",
            click: function() {
            	$(this).dialog("close");
            }
		}]			
	});
	
	$('#showAppXmlButton').click(function() {
		var xml = getAppXml();
		if(xml == null) {
			return;
		}
		$('#appXml').val(xml);
	});

	$('#saveAppButton').click(function() {
		var appName = $('#appName').val();
		var xml = getAppXml();
		if(xml == null) {
			if($('#appXml').val() != "") {
				if(!confirm("save with textarea xml?")) {
					return;
				}
				xml = $('#appXml').val();
			} else {
				alert("No app xml");
				return;
			}
		} else {
			$('#appXml').val(xml);
		}
		saveApp(appName, xml, $('#appCreator').val(), $('#appDescription').val());
	});

	//getAppList();
	workflowUtil.initAppListTable("appListTable", 300, 300, appSelected);
	workflowUtil.loadAppListTable("appListTable");

	$("#elFunctionTable").jqGrid({
		datatype: "local",
		width: 800,
		height: 500,
		rowNum: 100000,
	   	colNames:['function', 'description'],
	   	colModel:[
	   		{name:'funcName',index:'funcName', width:200, sortable:true, key: true},
	   		{name:'description',index:'description', width:600, cellattr: function (rowId, tv, rawObject, cm, rdata) { return 'style="white-space: normal;"' } }
	   	],
	   	ondblClickRow: function(rowid, ri, ci) {
			$("#" + $("#elFunctionResultField").val()).val(rowid);
			$("#elFunctionDialog").dialog("close");
		}
	});

	for(var i = 0; i < elFunctions.length; i++) {
		$("#elFunctionTable").jqGrid('addRowData', elFunctions[i][0], { funcName: elFunctions[i][0], description: elFunctions[i][1] });
	}
	
	$("#appLibListTable").jqGrid({
		datatype: "local",
		height: 250,
		width: 350,
		rowNum: 100000,
	   	colNames:['file', 'lib', 'length', 'date'],
	   	colModel:[
	   		{name:'fileName',index:'fileName', width:70, sortable:true},
	   		{name:'libPath',index:'libPath', width:50, sortable:true},
	   		{name:'length',index:'length', width:50, sortable:true, align: "right"},
	   		{name:'lastModifiedTime',index:'lastModifiedTime', width:80, sortable:true, formatter: dateFormatter}
	   	]
	});

	$("#appLibSelectTable").jqGrid({
		datatype: "local",
		height: 170,
		width: 675,
		rowNum: 100000,
	   	colNames:['file', 'lib', 'length', 'date'],
	   	colModel:[
	   		{name:'fileName',index:'fileName', width:200, sortable:true},
	   		{name:'libPath',index:'libPath', width:100, sortable:true},
	   		{name:'length',index:'length', width:200, sortable:true, align: "right"},
	   		{name:'lastModifiedTime',index:'lastModifiedTime', width:100, sortable:true, formatter: dateFormatter}
	   	],
	   	onSelectRow: function(rowid) {
	   		if($("#appLibSelectDialog_queryDiv").css("display") != "none") {
	   			var libPath = $("#appLibSelectTable").jqGrid('getCell', rowid, 'libPath');
	   			var filePath = ((libPath == null || libPath == "") ? rowid : libPath + "/" + rowid);
				var query = workflowUtil.getQueryInFile(filePath, $("#appName").val());
				$("#appLibSelectDialog_query").val(query);			
	   		}
		},
	   	ondblClickRow: function(rowid, ri, ci) {
			if(libSelectDialogParams != null) {
				for(var i = 0; i < libSelectDialogParams.length; i++) {
					var value = "";
					if(libSelectDialogParams[i][0] == "query") {
						value = workflowUtil.getQueryInFile(rowid, $("#appName").val());
					} else {
						value = $("#appLibSelectTable").jqGrid('getCell', rowid, libSelectDialogParams[i][0]);
					}
		    		$("#" + libSelectDialogParams[i][1]).val(value);	
				}
			} 
    		$("#appLibSelectDialog").dialog("close");
    	}
	});

	$("#actionDefaultPropertyTable").jqGrid({
		datatype: "local",
		height: 250,
		width: 580,
		rowNum: 100000,
		data: defaultHiveProperties,
	   	colNames:['name', 'value'],
	   	colModel:[
	   		{name:'name',index:'name', width:70, sortable:true, key: true},
	   		{name:'value',index:'value', width:70, sortable:false}
	   	],
		ondblClickRow: function(rowid, ri, ci) {
			$("#" + actionPropertyReturnPrefix + "DialogPropertyName").val($("#actionDefaultPropertyTable").jqGrid('getCell', rowid, 'name'));
			$("#" + actionPropertyReturnPrefix + "DialogPropertyValue").val($("#actionDefaultPropertyTable").jqGrid('getCell', rowid, 'value'));
    		$("#actionPropertyDialog").dialog("close");
		}
	});

	var propertyTables = ['shell', 'java', 'queryAction'];
	var propertyButtons = ['Shell', 'Java', 'QueryAction'];
	var tableHeights = [90, 90, 80];
	for(var i = 0; i < propertyTables.length; i++) {
		var prefix = propertyTables[i];
		$("#" + propertyTables[i] + "DialogPropertyTable").jqGrid({
			datatype: "local",
			height: tableHeights[i],
			width: 760,
			rowNum: 100000,
		   	colNames:['name', 'value'],
		   	colModel:[
		   		{name:'name',index:'name', width:70, sortable:true, key: true},
		   		{name:'value',index:'value', width:70, sortable:false}
		   	],
		   	onSelectRow: function(id) {
				var controlPrefix = $(this).attr('id').substring(0, $(this).attr('id').indexOf("DialogPropertyTable"));
				$("#" + controlPrefix + "DialogPropertyName").val($(this).jqGrid('getCell', id, 'name'));
				$("#" + controlPrefix + "DialogPropertyValue").val($(this).jqGrid('getCell', id, 'value'));
			}
		});

		$("#new" + propertyButtons[i] + "PropertyButton").bind('click', {prefix: prefix}, function(event) {
			$("#" + event.data.prefix + "DialogPropertyName").val('');
			$("#" + event.data.prefix + "DialogPropertyValue").val('');
		});

		$("#delete" + propertyButtons[i] + "PropertyButton").bind('click', {prefix: prefix}, function(event) {
			var tableName = event.data.prefix + "DialogPropertyTable";
			var name = $("#" + tableName).jqGrid("getGridParam", "selrow");
			$("#" + tableName).jqGrid('delRowData', name);
		});
		
		$("#save" + propertyButtons[i] + "PropertyButton").bind('click', {prefix: prefix}, function(event) {
			var name = $("#" + event.data.prefix + "DialogPropertyName").val();
			if(name == null || name == "") {
				alert("No name");
				return;
			}
			var value = $("#" + event.data.prefix + "DialogPropertyValue").val();

			var propertyData = $("#" + event.data.prefix + "DialogPropertyTable")[0].p.data;

			var matched = false;
			for(var j = 0; j < propertyData.length; j++) {
				if(propertyData[j].name == name) {
					matched = true;
					break;
				}
			}
			if(!matched) {
				$("#" + event.data.prefix + "DialogPropertyTable").jqGrid('addRowData', name, {name: name, value: value});
			} else {
				$("#" + event.data.prefix + "DialogPropertyTable").jqGrid('setCell', name, 'value', value);
			}
		});
	}
		
	$("#hiveQueryTable").jqGrid({
		datatype: "local",
		height: 170,
		width: 675,
		rowNum: 100000,
	   	colNames:['category', 'name', 'created', 'query'],
	   	colModel:[
	   		{name:'category',index:'category', width:150, sortable:true},
	   		{name:'queryName',index:'queryName', width:150, sortable:false, sortable:true},
	   		{name:'createdAt',index:'createdAt', width:150, sortable:false, formatter: dateFormatter},
	   		{name:'query',index:'query', width:70, sortable:false, hide:true}
	   	],
		onSelectRow: function(id) {
			$("#hiveQueryDialog_query").val($("#hiveQueryTable").jqGrid('getCell', id, 'query'));
		}
	});
	
	$("#jobDefaultPropertyTable").jqGrid({
		datatype: "local",
		height: 250,
		width: 580,
		rowNum: 100000,
		data: defaultJobProperties,
	   	colNames:['name', 'value'],
	   	colModel:[
	   		{name:'name',index:'name', width:70, sortable:true, key: true},
	   		{name:'value',index:'value', width:70, sortable:false}
	   	],
		ondblClickRow: function(rowid, ri, ci) {
			$("#saveMapReducePropertyName").val($("#jobDefaultPropertyTable").jqGrid('getCell', rowid, 'name'));
    		$("#jobPropertyDialog").dialog("close");
		}
	});

	$("#mapReducePropertyTable").jqGrid({
		datatype: "local",
		height: 190,
		width: 760,
		rowNum: 100000,
		data: defaultMrJobProperty,
	   	colNames:['name', 'value'],
	   	colModel:[
	   		{name:'name',index:'name', width:70, sortable:true, key: true},
	   		{name:'value',index:'value', width:70, sortable:false}
	   	],
		onSelectRow: function(id) {
			$("#saveMapReducePropertyName").val($("#mapReducePropertyTable").jqGrid('getCell', id, 'name'));
			$("#saveMapReducePropertyValue").val($("#mapReducePropertyTable").jqGrid('getCell', id, 'value'));
		}		
	});

	$("#jobLibClassListTable").jqGrid({
		datatype: "local",
		height: 350,
		width: 780,
		rowNum: 100000,
	   	colNames:['class'],
	   	colModel:[
	   		{name:'class',index:'class', width:70, sortable:true, key: true}
	   	], 
	   	ondblClickRow: function(rowid, ri, ci) {
			$("#" + $("#jobLibClassListDialog_returnId").val()).val(rowid);
			$("#jobLibClassListDialog").dialog("close");
		}
	});

	$("#decisionCaseTable").jqGrid({
		datatype: "local",
		height: 150,
		width: 600,
		rowNum: 100000,
	   	colNames:['to', 'condition', 'toId'],
	   	colModel:[
	   		{name:'toName', index:'toName', width:100, sortable:true},
	   		{name:'condition', index:'condition', width:500, sortable: false},
	   		{name:'toId', index:'toId', width:500, sortable: false, key: true, hidden: true},
	   	]
	});

	$("#fsDialogCommandTable").jqGrid({
		datatype: "local",
		height: 150,
		width: 550,
		rowNum: 100000,
	   	colNames:['command', 'command_hidden'],
	   	colModel:[
	   		{name:'command_view', index:'command_view', width:100, sortable: false, formatter: function(val) { return val.replace(/</g,"&lt;").replace(/>/g, "&gt;") }},
	   		{name:'command', index:'command', width:100, sortable: false, hidden:true}
	   	]
	});

	$("#addLibButton").click(function() {
		var appName = $("#appName").val();
		if(appName == null || appName == "") {
			alert("No app name");
			return;
		}
		$("#libAppName").val(appName);

    	$('#libUploadMessage').html('');

    	addLibDialogCallback = null;
    	
		$("#appLibDialog").dialog('open');
	});

	$("#uploadAppLibButton").click(function() {
		var appName = $("#appName").val();
		if(appName == null || appName == "") {
			alert("No app name");
			return;
		}
		$("#libAppName").val(appName);

    	$('#libUploadMessage').html('');

    	addLibDialogCallback = null;
    	
		$("#appLibDialog").dialog('open');
	});

	$("#refreshLibButton").click(function() {
		var appName = $("#appName").val();
		if(appName == null || appName == "") {
			alert("No app name");
			return;
		}
		refreshLibFileTable(appName);
	});

	$("#removeLibButton").click(function() {
		var appName = $("#appName").val();
		if(appName == null || appName == "") {
			alert("No app name");
			return;
		}

		var fileName = $("#appLibListTable").jqGrid('getGridParam', 'selrow');
		if(fileName == null || fileName == "" || fileName == "undefined") {
			alert("Select file");
			return;
		}

		if(!confirm("Deleting " + fileName)) {
			return;
		}

		var libPath = $("#appLibListTable").jqGrid('getCell', fileName, 'libPath');
		
		$.ajax({
			url: APPLICATION_CONTEXT + 'workflow/removeAppLibFile.do', 
			type: 'GET',
			async: false,
			data: {
				appName: appName,
				fileName: fileName,
				libPath: libPath
			},
			success: function(data) {
				if(!data.success) {
					alert(data.msg);
				} 
				refreshLibFileTable(appName);
			}
		});
	});

	$("#appDesignRunNow").click(function() {
		if(designSaved == false) {
			alert('not saved');
			return;
		}
		var appName =  $("#appName").val();
		if(!confirm("Are you sure run " + appName)) {
			return;
		}
		var appInfo = workflowUtil.getTableData("appListTable", appName);
		if(appInfo == null) {
			alert('select application.');
			return;
		}		
		if(appInfo.xml == null || appInfo.xml == "") {
			alert("Not saved app");
			return;
		}
		workflowUtil.showRunAppDialog(appInfo);
	});
	
	$("#runAppButton").click(function() {
		var appInfo = workflowUtil.getTableSelectedData("appListTable");
		if(appInfo == null) {
			alert('select application.');
			return;
		}		
		if(appInfo.xml == null || appInfo.xml == "") {
			alert("Not saved app");
			return;
		}
		workflowUtil.showRunAppDialog(appInfo);
	});

	$("#refreshAppButton").click(function() {
		workflowUtil.loadAppListTable("appListTable");
	});
	
	$("#newAppButton").click(function() {
		$("#newAppDialog_name").val('');
		$("#newAppDialog").dialog("open");
	});

	$("#removeAppButton").click(function() {
		workflowUtil.deleteApp('appListTable', function(appName) {
			alert(appName + " removed");
			workflowUtil.loadAppListTable("appListTable");
			clearAllInputs();
			designManager.clearAllItems();
		});
	});

	//////////////////////////////////
	//<QueryAction Dialog Button>
	$("#addQueryPrepareButton").click(function() {
		var item = $("#queryActionDialog_prepareItem").val();
		var path = $("#queryActionDialog_preparePath").val();
		if(path == null || path == "") {
			alert("No path");
			return;
		}
		var oldValue = $("#queryActionDialog_prepare").val();
		if(oldValue != "") {
			oldValue += "\n";
		}
		var xml = '<' + item + ' path="' + path + '"/>';
		$("#queryActionDialog_prepare").val(oldValue + xml);
		$("#queryActionDialog_preparePath").val('');
	});

	$("#addQueryParamButton").click(function() {
		var item = $("#queryActionDialog_paramItemText").val();
		if(item == null || item == "") {
			alert("No item");
			return;
		}
		var value = $("#queryActionDialog_paramValue").val();
		if(value == null || value == "") {
			alert("No value");
			return;
		}
		var oldValue = $("#queryActionDialog_param").val();
		if(oldValue != "") {
			oldValue += "\n";
		}
		var xml = '<param>' + item + '=' + value + '</param>';
		$("#queryActionDialog_param").val(oldValue + xml);
		$("#queryActionDialog_paramValue").val('');
	});
	//</QueryAction Dialog Button>
	
	//<MapReduce Dialog Button>
	$("#newMapReducePropertyButton").click(function() {
		$("#saveMapReducePropertyName").val('');
		$("#saveMapReducePropertyValue").val('');
	});

	$("#saveMapReducePropertyButton").click(function() {
		var name = $("#saveMapReducePropertyName").val();
		if(name == null || name == "") {
			alert("No name");
			return;
		}
		var value = $("#saveMapReducePropertyValue").val();

		var propertyData = $("#mapReducePropertyTable")[0].p.data;

		var matched = false;
		for(var i = 0; i < propertyData.length; i++) {
			if(propertyData[i].name == name) {
				matched = true;
				break;
			}
		}
		if(!matched) {
			$("#mapReducePropertyTable").jqGrid('addRowData', name, {name: name, value: value});
		} else {
			$("#mapReducePropertyTable").jqGrid('setCell', name, 'value', value);
		}
	});

	$("#deleteMapReducePropertyButton").click(function() {
		var name = $("#mapReducePropertyTable").jqGrid("getGridParam", "selrow");
		$("#mapReducePropertyTable").jqGrid('delRowData', name);
	});

	$('input[name=mapReduceJobType]').change(function() {
		var jobType = $('input[name=mapReduceJobType]:checked').val()
		if(jobType == "streaming") {
			if($("#map-reduceStreamingXml").val() == null || $("#map-reduceStreamingXml").val() == "") {
				$("#map-reduceStreamingXml").val(defaultXmls.get("streaming"));
			}
			$("#map-reduceDialog-tab").tabs('select', 1);
		} else if(jobType == "pipe") {
			if($("#map-reducePipeXml").val() == null || $("#map-reducePipeXml").val() == "") {
				$("#map-reducePipeXml").val(defaultXmls.get("pipes"));
			}
			$("#map-reduceDialog-tab").tabs('select', 2);
		} else {
			$("#map-reduceDialog-tab").tabs('select', 0);
		}
	});

	$("#jobLibClassLibFiles").change(function() {
		var filePath = $("#jobLibClassLibFiles").val();
		if(filePath == null || filePath == "") {
			return;
		}
		$.ajax({
			url: APPLICATION_CONTEXT + 'workflow/getAppLibFile.do', 
			type: 'GET',
			async: false,
			data: { filePath: filePath }, 
			success: function(result) {
				if(!result.success) {
					alert(result.msg);
					return;
				} else {
					libFileClassInfo = result.data;
					$("#jobLibClassType").empty();

					$("#jobLibClassType").append('<option></option>');
					var mapperClass = 0;
					for(classType in libFileClassInfo.classList) {
						$("#jobLibClassType").append('<option value="' + classType + '">' + classType + '</option>');
					}
					//$("#jobLibClassType option:first").attr('selected','selected');
				}
			}
		});			
	});

	$("#jobLibClassType").change(function() {
		var classList = libFileClassInfo.classList[$("#jobLibClassType").val()];
		if(classList == null || classList == "") {
			return;
		}
		$("#jobLibClassListTable").jqGrid("clearGridData");
		for(var i = 0; i < classList.length; i++) {
			$("#jobLibClassListTable").jqGrid('addRowData', classList[i], {class: classList[i]});
		}
	});

	var fileButtons = ['map-reduce', 'queryAction', 'java'];

	for(var i = 0; i < fileButtons.length; i++) {
		$("#" + fileButtons[i] + "FileButton").bind('click', {prefix: fileButtons[i] }, function(event) {
			var item = $("#" + event.data.prefix + "Dialog_fileItem").val();
			var file = $("#" + event.data.prefix + "Dialog_fileText").val();
			if(file == null || file == "") {
				alert("No file");
				return;
			}
			var oldValue = $("#" + event.data.prefix + "Dialog_file").val();
			if(oldValue != "") {
				oldValue += "\n";
			}
			var xml = '<' + item + '>' + file + '</' + item + '>';
			$("#" + event.data.prefix + "Dialog_file").val(oldValue + xml);
			$("#" + event.data.prefix + "Dialog_fileText").val('');
		});
	}
		
	$("#addPrepareButton").click(function() {
		var item = $("#map-reduceDialog_prepareItem").val();
		var path = $("#map-reduceDialog_preparePath").val();
		if(path == null || path == "") {
			alert("No path");
			return;
		}
		var oldValue = $("#map-reduceDialog_prepare").val();
		if(oldValue != "") {
			oldValue += "\n";
		}
		var xml = '<' + item + ' path="' + path + '"/>';
		$("#map-reduceDialog_prepare").val(oldValue + xml);
		$("#map-reduceDialog_preparePath").val('');
	});
	//</MapReduce Dialog Button>
	
	//////////////////////////////////
	//<Java Dialog Button>
	$("#addJavaArgsButton").click(function() {
		var item = $("#javaDialog_argsText").val();
		if(item == null || item == "") {
			alert("No args");
			return;
		}
		var oldValue = $("#javaDialog_args").val();
		if(oldValue != "") {
			oldValue += "\n";
		}
		var xml = '<arg>' + item + '</arg>';
		$("#javaDialog_args").val(oldValue + xml);
		$("#javaDialog_argsText").val('');
	});
	//</Java Dialog Button>
	
	//<Shell Dialog Button>
	$("#addShellArgsButton").click(function() {
		var item = $("#shellDialog_argumentText").val();
		if(item == null || item == "") {
			alert("No argument");
			return;
		}
		var oldValue = $("#shellDialog_argument").val();
		if(oldValue != "") {
			oldValue += "\n";
		}
		var xml = '<argument>' + item + '</argument>';
		$("#shellDialog_argument").val(oldValue + xml);
		$("#shellDialog_argumentText").val('');
	});


	$("#addShellEnvVarButton").click(function() {
		var itemName = $("#shellDialog_envVarNameText").val();
		if(itemName == null || itemName == "") {
			alert("No env variable name");
			return;
		}
		var itemValue = $("#shellDialog_envVarValueText").val();
		if(itemValue == null || itemValue == "") {
			alert("No env variable value");
			return;
		}
		var oldValue = $("#shellDialog_envVar").val();
		if(oldValue != "") {
			oldValue += "\n";
		}
		var xml = '<env-var>' + itemName + '=' + itemValue + '</env-var>';
		$("#shellDialog_envVar").val(oldValue + xml);
		$("#shellDialog_envVarNameText").val('');
		$("#shellDialog_envVarValueText").val('');
	});

	$("#addShellPrepareButton").click(function() {
		var item = $("#shellDialog_prepareItem").val();
		var path = $("#shellDialog_preparePath").val();
		if(path == null || path == "") {
			alert("No path");
			return;
		}
		var oldValue = $("#shellDialog_prepare").val();
		if(oldValue != "") {
			oldValue += "\n";
		}
		var xml = '<' + item + ' path="' + path + '"/>';
		$("#shellDialog_prepare").val(oldValue + xml);
		$("#shellDialog_preparePath").val('');
	});	
	//</Shell Dialog Button>
	
	$("#addSshArgsButton").click(function() {
		var item = $("#sshDialog_argsText").val();
		if(item == null || item == "") {
			alert("No item");
			return;
		}
		var oldValue = $("#sshDialog_args").val();
		if(oldValue != "") {
			oldValue += "\n";
		}
		var xml = '<args>' + item + '</args>';
		$("#sshDialog_args").val(oldValue + xml);
		$("#sshDialog_argsText").val('');
	});
		
	$("#itemXmlRefreshButton").click(function() {
		var itemId = $("#actionPropertyTab_itemId").val();
		if(itemId == null || itemId == "") {
			alert("No selected item.");
			return;
		}

		$("#propertyXml").val(designManager.getItem(itemId).getXml());
	});

	$("#addSwitchCaseButton").click(function() {
		var caseToId = $("#decisionDialog_caseTo option:selected").val();
		var caseToName = $("#decisionDialog_caseTo option:selected").text();
		var condition = $("#decisionDialog_condition").val();
		var defaultYn = $("#decisionDialog_default").is(':checked');

		if(caseToId == null || caseToId == "") {
			alert('no case to');
			return;
		}

		if(!defaultYn && (condition == null || condition == "")) {
			alert('no condition');
			return;
		}
		if(defaultYn) {
			condition = 'default';
		}

		var gridData = $("#decisionCaseTable")[0].p.data;
		for(var i = 0; i < gridData.length; i++) {
			if(gridData[i].toId == caseToId) {
				alert(caseToName + " already added");
				return;
			}
			if(defaultYn && gridData[i].condition == 'default') {
				alert("default already added");
				return;
			}
		}
		$("#decisionDialog_default").attr('checked', false);
		$("#decisionCaseTable").jqGrid('addRowData', caseToId, { toId:caseToId, toName:caseToName, condition: condition } );
		$("#decisionDialog_condition").val('');
	});

	$("#deleteSwitchCaseButton").click(function() {
		var toId = $("#decisionCaseTable").jqGrid("getGridParam", "selrow");
		if(toId == null || toId == "") {
			alert('select case');
			return;
		}
		$("#decisionCaseTable").jqGrid('delRowData', toId);
	});

	$("#addForkPathButton").click(function() {
		var pathToId = $("#forkDialog_pathTo option:selected").val();
		var pathToName = $("#dforkDialog_pathTo option:selected").text();

		if(pathToId == null || pathToId == "") {
			alert('no path to');
			return;
		}

		var gridData = $("#forkPathTable")[0].p.data;
		for(var i = 0; i < gridData.length; i++) {
			if(gridData[i].toId == pathToId) {
				alert(pathToName + " already added");
				return;
			}
		}
		$("#forkPathTable").jqGrid('addRowData', pathToId, pathToName );
	});

	$("#deleteForkPathButton").click(function() {
		var toId = $("#forkPathTable").jqGrid("getGridParam", "selrow");
		if(toId == null || toId == "") {
			alert('select path');
			return;
		}
		$("#forkPathTable").jqGrid('delRowData', toId);
	});

	$("#itemSettingButton").click(function() {
		var itemId = $("#currentConfigItemId").val();
		if(itemId == null || itemId == "") {
			alert("select item");
		}

		var selectedItem = designManager.getItem(itemId);
		selectedItem.showConfigDialog();
	});

	$("#fsDialogAddButton").click(function() {
		var operation = $("#fsDialog_operation").val();
		if(operation == "delete" || operation == "mkdir") {
			var path = $("#fsDialog_path").val();
			if(path == null || path == "") {
				alert("no path");
				return;
			} 
			var command = '<' + operation + ' path="' + path + '"/>';
			$("#fsDialogCommandTable").jqGrid('addRowData', (new Date()).getTime(),  { command: command, command_view: command });
		} else if(operation == "move") {
			var source = $("#fsDialog_source").val();
			if(source == null || source == "") {
				alert("no source");
				return;
			} 
			var target = $("#fsDialog_target").val();
			if(target == null || target == "") {
				alert("no target");
				return;
			} 
			var command = '<move source="' + source + '" target="' + target + '"/>';
			$("#fsDialogCommandTable").jqGrid('addRowData', (new Date()).getTime(),  { command: command, command_view: command });
		} else if(operation == "chmod") {
			var path = $("#fsDialog_chmodPath").val();
			if(path == null || path == "") {
				alert("no path");
				return;
			} 
			var permission = $("#fsDialog_permissions").val();
			if(permission == null || permission == "") {
				alert("no permission");
				return;
			}
			var dirFiles = ($("#fsDialog_dirFiles").attr('checked')) ? 'true' : 'false';
			var command = '<chmod path="' + path + '" permissions="' + permission + ' dir-files="' + dirFiles + '"/>';
			$("#fsDialogCommandTable").jqGrid('addRowData', (new Date()).getTime(), { command: command, command_view: command });
		} else {
			alert("select operation");
			return;
		}
	});

	$("#fsDialogDeleteButton").click(function() {
		var rowid = $("#fsDialogCommandTable").jqGrid('getGridParam', 'selrow');
		$("#fsDialogCommandTable").jqGrid('delRowData', rowid);
	});

	$("#appLibSelectDialogAddFileButton").click(function() {
		var appName = $("#appName").val();
		if(appName == null || appName == "") {
			alert("No app name");
			return;
		}
		$("#libAppName").val(appName);

    	$('#libUploadMessage').html('');

    	addLibDialogCallback = function() {
    		getLibFiles(appName, function(data) {
    			$("#appLibSelectTable").jqGrid("clearGridData");
    			for(var i = 0; i < data.length; i++) {
    				if(data[i].fileName == "workflow.xml" || data[i].fileName == "cloumon.dat") {
    					continue;
    				}
    				$("#appLibSelectTable").jqGrid('addRowData', data[i].fileName, data[i]);
    			}
    			$("#appLibSelectDialog").dialog("open");
    		});
    	};
    	
		$("#appLibDialog").dialog('open');
	});
	
	$('#layout-container').layout({
		center: {
			paneSelector: '#centerPane',
			closable: false,
			resizable: false,
			slidable: false,
			onresize: resizeLayout,
	    	triggerEventsOnLoad: true  // resize the grin on load also
	  	},
	  	west: {
	  		paneSelector: '#westPane',
	    	fxName: "slide",
	    	size:    400,
	    	maxSize: 600,
	    	onresize: resizeLayout,
	    	triggerEventsOnLoad: true,
	  	},
		east: {
			paneSelector: '#eastPane',
	    	size:    400,
	    	maxSize: 600,
			closable: false,
			resizable: false,
			slidable: false,
	    	onresize: resizeLayout,
	    	triggerEventsOnLoad: true,
		}
	});

	$("#newAppDialog_name").keypress(function(event) {
		if(event.which == 13) {
			addNewApp();
		}
	});

	$("#fsDialog_operation").change(function() {
		var operation = $("#fsDialog_operation").val();
		if(operation == "delete" || operation == "mkdir") {
			$("#fsDialog_deleteDiv").show();
			$("#fsDialog_moveDiv").hide();
			$("#fsDialog_chmodDiv").hide();
		} else if(operation == "move") {
			$("#fsDialog_deleteDiv").hide();
			$("#fsDialog_moveDiv").show();
			$("#fsDialog_chmodDiv").hide();
		} else if(operation == "chmod") {
			$("#fsDialog_deleteDiv").hide();
			$("#fsDialog_moveDiv").hide();
			$("#fsDialog_chmodDiv").show();
		}
	});

	if(editAppName != null && editAppName != "") {
		$("#appListTable").setSelection(editAppName, true);
	}
});

function addNewApp() {
	var appName = $("#newAppDialog_name").val();
	if(appName == null || appName == "") {
		alert("No app name");
		return false;
	}
	
	var gridData = $("#appListTable")[0].p.data;
	for(var i = 0; i < gridData.length; i++) {
		if(gridData[i].appName == appName) {
			alert("Already exists application[" + appName + "]");
			return false;
		}
	}
	clearAllInputs();

	designManager.clearAllItems();

	var startItem = designManager.createNewItem("start");
	startItem.attachTo('appDesign');

	var endItem = designManager.createNewItem("end");
	endItem.attachTo('appDesign');

	var killItem = designManager.createNewItem("kill");
	killItem.attachTo('appDesign');	

	$('#appName').val(appName);
	$("#tab-container").tabs("select", 1);
	$("#newAppDialog").dialog("close");

	designSaved = false;
	return true;
}

function setDecisionCondition() {
	var condition = $("#decisionConditionDialog_condition").val();
	if(condition == null || condition == "") {
		alert('no condition');
		return false;
	}
	var sourceId = $("#decisionConditionDialog_sourceId").val();
	var targetId = $("#decisionConditionDialog_targetId").val();

	var sourceItem = designManager.getItem(sourceId);
	var targetItem = designManager.getItem(targetId);

	sourceItem.setCondition(targetItem, condition);
	return true;
}

function cancelDecisionConnection() {
	var sourceId = $("#decisionConditionDialog_sourceId").val();
	var targetId = $("#decisionConditionDialog_targetId").val();

	var sourceItem = designManager.disconnectItem(sourceId, targetId, false);
}

/*
 * for new application
 */
function clearAllInputs() {
	$('#appName').val('');
	$('#appXml').val('');
	$('#appCreator').val('');
	$('#appDescription').val('');

	$('#actionPropertyTab_itemName').val('');
	$('#actionPropertyTab_itemId').val('');
	$('#propertyXml').val('');
	$('#appLibListTable').jqGrid("clearGridData");
}

/*
 * get application info from hdfs. and draw flow
 */
function appSelected(appInfoParam) {
	$.ajax({
		url: APPLICATION_CONTEXT + 'workflow/getApp.do', 
		type: 'GET',
		async: false,
		data: {appName: appInfoParam.appName},
		success: function(result) {
			if(!result.success) {
				alert(result.msg);
				return;
			} else {
				var appInfo = result.data;
				$('#appName').val(appInfo.appName);
				$('#appXml').val(appInfo.xml);
				$('#appCreator').val(appInfo.creator);
				$('#appDescription').val(appInfo.description);
				designManager.clearAllItems();
				
				var positionMap = new HashMap();

				if(appInfo.positions != null) {
					var positions = eval(appInfo.positions);
					for(var i = 0; i < positions.length; i++) {
						positionMap.put(positions[i].name, {top: positions[i].top, left: positions[i].left});
					}
				}

				var items = appInfo.items;

				designManager.createItemsWithServerData(items);

				var createdItems = designManager.allItems.values();

				for(var i = 0; i < createdItems.length; i++) {
					var position = positionMap.get(createdItems[i].name);
					if(position == null) {
						createdItems[i].attachTo('appDesign');	
					} else {
						createdItems[i].attachTo('appDesign', position.top, position.left);	
					}
				}
				designManager.connectAllItems();
				designSaved = true;
			}
		}
	});			
}

/*
 * get query(hive/pig) action configuration from dialog, and set item
 */
function setQueryActionInfo() {
	var itemId = $("#currentConfigItemId").val();
	
	var queryItem = designManager.getItem(itemId);
	if(queryItem == null) {
		alert("No selected item:" + itemId);
		return false;
	}
	if($("#queryActionDialog_name").val() == null || $("#queryActionDialog_name").val() == "") {
		alert('no name');
		return false;
	}
	
	if(!queryItem.setName($("#queryActionDialog_name").val())) {
		return false;
	}
	queryItem.jobTracker = $("#queryActionDialog_jobtrackerText").val();
	queryItem.nameNode = $("#queryActionDialog_namenodeText").val();
	queryItem.queryFile = $("#queryActionDialog_queryFile").val();
	queryItem.query = $("#queryActionDialog_query").val();
	queryItem.prepare = $("#queryActionDialog_prepare").val();
	queryItem.params = $("#queryActionDialog_param").val();
	queryItem.files = $("#queryActionDialog_file").val();

	
	var tableData = $("#queryActionDialogPropertyTable")[0].p.data;
	queryItem.configuration.clear();
	for(var i = 0; i < tableData.length; i++) {
		if(tableData[i].value != "") {
			queryItem.configuration.put(tableData[i].name, tableData[i].value);
		}
	}
	queryItem.saveQueryFile($("#appName").val());

	$("#propertyXml").val(queryItem.getXml());
	
	return true;	
}

function setMapReduceActionInfo() {
	var itemId = $("#currentConfigItemId").val();
	
	var mapreduceItem = designManager.getItem(itemId);
	if(mapreduceItem == null) {
		alert("No selected item:" + itemId);
		return false;
	}
	if($("#map-reduceDialog_name").val() == null || $("#map-reduceDialog_name").val() == "") {
		alert('no name');
		return false;
	}
	
	if(!mapreduceItem.setName($("#map-reduceDialog_name").val())) {
		return false;
	}
	mapreduceItem.jobTracker = $("#map-reduceDialog_jobtrackerText").val();
	mapreduceItem.nameNode = $("#map-reduceDialog_namenodeText").val();
	mapreduceItem.prepare = $("#map-reduceDialog_prepare").val();
	mapreduceItem.files = $("#map-reduceDialog_file").val();
	
	var tableData = $("#mapReducePropertyTable")[0].p.data;
	mapreduceItem.configuration.clear();
	for(var i = 0; i < tableData.length; i++) {
		if(tableData[i].value != "") {
			mapreduceItem.configuration.put(tableData[i].name, tableData[i].value);
		}
	}
	mapreduceItem.jobType = $('input[name=mapReduceJobType]:checked').val();
	if(mapreduceItem.jobType == "streaming") {
		mapreduceItem.streaming = $("#map-reduceStreamingXml").val();
	} else if(mapreduceItem.jobType == "pipe") {
		mapreduceItem.pipe = $("#map-reducePipeXml").val();
	} else {
		mapreduceItem.streaming = null;
		mapreduceItem.pipe = null;
	}		

	$("#propertyXml").val(mapreduceItem.getXml());
	
	return true;	
}

function setJavaActionInfo() {
	var itemId = $("#currentConfigItemId").val();
	
	var javaItem = designManager.getItem(itemId);
	if(javaItem == null) {
		alert("No selected item:" + itemId);
		return false;
	}
	if($("#javaDialog_name").val() == null || $("#javaDialog_name").val() == "") {
		alert('no name');
		return false;
	}
	
	if(!javaItem.setName($("#javaDialog_name").val())) {
		return false;
	}
	javaItem.jobTracker = $("#javaDialog_jobtrackerText").val();
	javaItem.nameNode = $("#javaDialog_namenodeText").val();
	javaItem.mainClass = $("#javaDialog_mainClass").val();
	javaItem.args = $("#javaDialog_args").val();
	javaItem.javaOpts = $("#javaDialog_javaOpts").val();
	javaItem.files = $("#javaDialog_file").val();
	javaItem.captureOutput = $('#javaDialog_captureOutput').attr('checked');
	
	var tableData = $("#javaDialogPropertyTable")[0].p.data;
	javaItem.configuration.clear();
	for(var i = 0; i < tableData.length; i++) {
		if(tableData[i].value != "") {
			javaItem.configuration.put(tableData[i].name, tableData[i].value);
		}
	}

	$("#propertyXml").val(javaItem.getXml());
	
	return true;	
}

function setShellActionInfo() {
	var itemId = $("#currentConfigItemId").val();
	
	var shellItem = designManager.getItem(itemId);
	if(shellItem == null) {
		alert("No selected item:" + itemId);
		return false;
	}
	if($("#shellDialog_name").val() == null || $("#shellDialog_name").val() == "") {
		alert('no name');
		return false;
	}
	
	if(!shellItem.setName($("#shellDialog_name").val())) {
		return false;
	}
	shellItem.jobTracker = $("#shellDialog_jobtrackerText").val();
	shellItem.nameNode = $("#shellDialog_namenodeText").val();
	shellItem.exec = $("#shellDialog_exec").val();
	shellItem.argument = $("#shellDialog_argument").val();
	shellItem.prepare = $("#shellDialog_prepare").val();
	shellItem.envVar = $("#shellDialog_envVar").val();
	shellItem.captureOutput = $('#shellDialog_captureOutput').attr('checked');
	
	var tableData = $("#shellDialogPropertyTable")[0].p.data;
	shellItem.configuration.clear();
	for(var i = 0; i < tableData.length; i++) {
		if(tableData[i].value != "") {
			shellItem.configuration.put(tableData[i].name, tableData[i].value);
		}
	}

	$("#propertyXml").val(shellItem.getXml());
	
	return true;	
}

function setSshActionInfo() {
	var itemId = $("#currentConfigItemId").val();
	
	var sshItem = designManager.getItem(itemId);
	if(sshItem == null) {
		alert("No selected item:" + itemId);
		return false;
	}
	if($("#sshDialog_name").val() == null || $("#sshDialog_name").val() == "") {
		alert('no name');
		return false;
	}
	
	if(!sshItem.setName($("#sshDialog_name").val())) {
		return false;
	}
	sshItem.host = $("#sshDialog_host").val();
	sshItem.command = $("#sshDialog_command").val();
	sshItem.args = $("#sshDialog_args").val();
	sshItem.captureOutput = $('#sshDialog_captureOutput').attr('checked');
	
	$("#propertyXml").val(sshItem.getXml());
	
	return true;	
}

function setUserDefinedActionInfo() {
	var itemId = $("#currentConfigItemId").val();
	
	var item = designManager.getItem(itemId);
	if(item == null) {
		alert("No selected item:" + itemId);
		return false;
	}

	if($("#userDefineDialog_name").val() == null || $("#userDefineDialog_name").val() == "") {
		alert('no name');
		return false;
	}
	
	if(!item.setName($("#userDefineDialog_name").val())) {
		return false;
	}
	item.actionXml = $("#userDefineDialog_actionXml").val();
	
	$("#propertyXml").val(item.getXml());
	
	return true;	
}

function setDecisionInfo() {
	var itemId = $("#currentConfigItemId").val();
	var decisionItem = designManager.getItem(itemId);
	if(decisionItem == null) {
		alert("No selected item:" + itemId);
		return false;
	}
	if($("#decisionDialog_name").val() == null || $("#decisionDialog_name").val() == "") {
		alert('no name');
		return;
	}
	if(!decisionItem.setName($("#decisionDialog_name").val())) {
		return false;
	}

	decisionItem.caseMap.clear();
	var tableData = $("#decisionCaseTable")[0].p.data;
	for(var i = 0; i < tableData.length; i++) {
		decisionItem.caseMap.put(tableData[i].toId, {toId: tableData[i].toId, toName: tableData[i].toName, condition: tableData[i].condition} );
	}

	$("#propertyXml").val(decisionItem.getXml());

	decisionItem.reloadConnection();
	
	return true;
}

function showLibClassDialog(returnId) {
	var appName = $('#appName').val();
	if(returnId != null) {
		$("#jobLibClassListDialog_returnId").val(returnId); 
	}
	
	$("#jobLibClassLibFiles").empty();
	$('#jobLibClassType').empty();
	getLibFiles(appName, function(data) {
		$("#jobLibClassLibFiles").append('<option value=""></option>');
		var addCount = 0;
		for(var i = 0; i < data.length; i++) {
			if(workflowUtil.endsWith(data[i].fileName, ".jar")) {
				$("#jobLibClassLibFiles").append('<option value="' + data[i].fullPath + '">' + data[i].fileName + '</option>');
				addCount++;
			}
		}
		if(addCount > 0) {
			$("#jobLibClassLibFiles option:first").attr('selected','selected');
		}
	});

	if($("#jobLibClassListDialog").dialog('isOpen') == true) {
		return;
	}
	$("#jobLibClassListDialog").dialog("open");
}

function showLibSelectDialog(showQuery) {
	var appName = $('#appName').val();

	if(showQuery == null) {
		showQuery = true;
	}

	if(showQuery) {
		$("#appLibSelectDialog_queryDiv").show();
		$("#appLibSelectTable").setGridHeight(150);
	} else {
		$("#appLibSelectDialog_queryDiv").hide();
		$("#appLibSelectTable").setGridHeight(270);
	}
	$("#appLibSelectDialog_query").val('');

	getLibFiles(appName, function(data) {
		$("#appLibSelectTable").jqGrid("clearGridData");
		for(var i = 0; i < data.length; i++) {
			if(data[i].fileName == "workflow.xml" || data[i].fileName == "cloumon.dat") {
				continue;
			}
			$("#appLibSelectTable").jqGrid('addRowData', data[i].fileName, data[i]);
		}
		$("#appLibSelectDialog").dialog("open");
	});
}

function getDefaultJobProperties() {
	$.ajax({
		url: APPLICATION_CONTEXT + 'workflow/getDefaultJobProperties.do', 
		type: 'GET',
		async: false,
		success: function(result) {
			if(!result.success) {
				alert(result.msg);
				return;
			} else {
				defaultJobProperties = new Array();
				for(key in result.data) {
					defaultJobProperties.push({ name: key, value:  result.data[key] });
				}
			}
		}
	});		
}

function getDefaultHiveProperties() {
	$.ajax({
		url: APPLICATION_CONTEXT + 'workflow/getDefaultHiveProperties.do', 
		type: 'GET',
		async: false,
		success: function(result) {
			if(!result.success) {
				alert(result.msg);
				return;
			} else {
				defaultHiveProperties = new Array();
				for(key in result.data) {
					defaultHiveProperties.push({ name: key, value:  result.data[key] });
				}
			}
		}
	});		
}

function refreshLibFileTable(appName) {
	getLibFiles(appName, function(data) {
		$("#appLibListTable").jqGrid("clearGridData");
		for(var i = 0; i < data.length; i++) {
			if(data[i].fileName == "workflow.xml" || data[i].fileName == "cloumon.dat") {
				continue;
			}
			$("#appLibListTable").jqGrid('addRowData', data[i].fileName, data[i]);
		}
	});
}

function getOozieClusterInfo() {
	$.ajax({
		url: APPLICATION_CONTEXT + 'workflow/getOozieClusterInfo.do', 
		type: 'GET',
		async: false,
		success: function(result) {
			if(!result.success) {
				alert(result.msg);
				return;
			} else {
				var targets = ["map-reduceDialog", "queryActionDialog", "javaDialog", "shellDialog"];
				oozieClusterInfo = result.data;
				var nameNodes = result.data.nameNodes;
				var jobTrackers = result.data.jobTrackers;

				for(var i = 0; i < targets.length; i++) {
					$("#" + targets[i] + "_namenode").append('<option></option>');
					for(var j = 0; j < nameNodes.length; j++) {
						$("#" + targets[i] + "_namenode").append('<option>' + nameNodes[j] + '</option>');
					}
					$("#" + targets[i] + "_jobtracker").append('<option></option>');
					for(var j = 0; j < jobTrackers.length; j++) {
						$("#" + targets[i] + "_jobtracker").append('<option>' + jobTrackers[j] + '</option>');
					}
				}
			}
		}
	});
}

function getLibFiles(appName, callback) {
	$.ajax({
		url: APPLICATION_CONTEXT + 'workflow/getAppLibFiles.do', 
		type: 'GET',
		async: false,
		data: {
			appName: appName
		},
		success: function(result) {
			if(!result.success) {
				alert(result.msg);
				return;
			} else {
				callback(result.data)
			}
		}
	});	
}

function saveApp(appName, xml, creator, description) {
	if(!confirm("Are you sure saving oozie application [" + appName + "]")) {
		return;
	}

	var positions = designManager.getItemPositions();

	$.ajax({
		url: APPLICATION_CONTEXT + 'workflow/saveApp.do', 
		type: 'POST',
		async: false,
		data: {
			appName: appName,
			appXml: xml,
			creator: creator,
			description: description,
			positions: JSON.stringify(positions)
		},
		success: function(data) {
			if(!data.success) {
				alert(data.msg);
				return;
			} else {
				alert('Successfully saved.');
				//getAppList();
				designSaved = true;
				workflowUtil.loadAppListTable("appListTable");
				
				return;
			}
		}
	});
}

function showHiveQueryDialog() {
	if($('#queryActionDialog_prefix').val() != 'hive') {
		alert('avaliable in hive config');
		return;
	}
	$.ajax({
		url: APPLICATION_CONTEXT + 'workflow/getHiveQuery.do', 
		type: 'GET',
		async: false,
		success: function(result) {
			if(!result.success) {
				alert(result.msg);
				return;
			} else {
				$("#hiveQueryTable").jqGrid("clearGridData");
				for(var i = 0; i < result.data.length; i++) {
					$("#hiveQueryTable").jqGrid('addRowData', i, result.data[i]);
				}
				$("#hiveQueryDialog").dialog("open");
			}
		}
	});	
}

function getAppXml() {
	var appName = $('#appName').val();
	if(appName == '') {
		alert('No app name');
		return null;
	}
	if(!designManager.verifyItems()) {
		return null;
	}
	var xml = designManager.getApplicationXml(appName);
	return xml;
}

function addItem(nodeType, itemType) {
	var item = designManager.createNewItem(itemType);
	item.attachTo('appDesign');
}

--></script>
</head>
<body onunload="jsPlumb.unload();">
<div id="layout-container" style="width: 100%; height:100%; padding:0;">
	<div id="westPane" style="margin-left:0px; padding:0px">
		<div id="tab-container" style="border:0;padding:0px">
			<ul>
				<li><a href="#tab_1"><span>App List</span></a></li>
				<li><a href="#tab_2"><span>Action Control</span></a></li>
			</ul>
			<div id="tab_1">
				<div>
					<div style="margin-top:5px; float:left">
						<button id="runAppButton">run now</button>
					</div>
					<div style="margin-top:5px; float:right">
						<button id="refreshAppButton">refresh</button>
						<button id="newAppButton">new</button>
						<button id="removeAppButton">delete</button>
					</div>	
					<div style='clear:both'></div>			
					<div style="margin-top:5px;">
						<table id="appListTable"></table>
					</div>
				</div>
			</div>			
			<div id="tab_2">
				<div>
					<div id="workflow_entries">
						<h3><a href="#">Control</a></h3>
						<div>
							<div class="itemMenu" onclick="addItem('control', 'start')">Start</div>
							<div class="itemMenu" onclick="addItem('control', 'end')">End</div>
							<div class="itemMenu" onclick="addItem('control', 'kill')">Kill</div>
							<div class="itemMenu" onclick="addItem('control', 'decision')">Decision</div>
							<div class="itemMenu" onclick="addItem('control', 'fork')">Fork</div>
							<div class="itemMenu" onclick="addItem('control', 'join')">Join</div>
						</div>
						<h3><a href="#">Action</a></h3>
						<div>
							<div class="itemMenu" onclick="addItem('action', 'map-reduce')">MapReduce</div>
							<div class="itemMenu" onclick="addItem('action', 'hive')">Hive</div>
							<div class="itemMenu" onclick="addItem('action', 'pig')">Pig</div>
							<div class="itemMenu" onclick="addItem('action', 'fs')">HDFS</div>
							<div class="itemMenu" onclick="addItem('action', 'java')">Java Program</div>
							<div class="itemMenu" onclick="addItem('action', 'shell')">Shell</div>
							<div class="itemMenu" onclick="addItem('action', 'ssh')">SSH</div>
							<div class="itemMenu" onclick="addItem('action', 'sub-workflow')">Sub-Workflow</div>
							<div class="itemMenu" onclick="addItem('action', 'user-defined')">User Defined</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div id="centerPane" style="margin:0px; padding:0px">
		<div style="height:30px; background-color:#85b5d9;border: solid 1px #4297d7;-moz-border-radius: 5px;-webkit-border-radius: 5px; border-radius: 5px;">
			<div style="float:left;color: #2E6E9E; font-weight: bold; font-size:11px; margin-top:10px; margin-left: 10px">App Design</div>
			<div style="float:right;margin-top:10px;margin-right:10px"><button id="appDesignRunNow">run now</button></div>
			<div style="clear:both"></div>
		</div>
		<div id="appDesign" class="ui-widget ui-widget-content ui-corner-all">
		</div>
	</div>
	<div id="eastPane" style="margin:0px; padding:0px">
		<div style="height:30px; background-color:#85b5d9;border: solid 1px #4297d7;-moz-border-radius: 5px;-webkit-border-radius: 5px; border-radius: 5px;">
			<div style="color: #2E6E9E; font-weight: bold; font-size:11px; margin-top:10px; margin-left: 10px">Application property</div>
		</div>
		<div class="ui-widget">
			<div style="margin-top:5px">
				<span style='display:inline-block; width:60px; margin-left:10px'>App name:</span><input type='text' id='appName' style="width:100px" readonly="readonly"/>
				<button id='saveAppButton'>Save App</button>
				<button id='showAppXmlButton'>Generate xml</button>
			</div>
			<div id="propertyTabContainer" style="margin-top:5px">
				<ul>
					<li><a href="#appPropertyTab"><span>Application Info.</span></a></li>
					<li><a href="#appLibPropertyTab"><span>Library</span></a></li>
					<li><a href="#actionPropertyTab"><span>Action Property</span></a></li>
				</ul>
				<div id="appPropertyTab">
					<div style="margin-top:5px"><span style='display:inline-block; width:80px; margin-left:10px'>Creator:</span><input type='text' id='appCreator' style="width:230px"/></div>
					<div style="margin-top:5px"><span style='display:inline-block; width:80px; margin-left:10px'>Description:</span><input type='text' id='appDescription' style="width:230px"/></div>
					<div style="margin-top:5px"><span style='display:inline-block; width:120px; margin-left:10px'>App Definition:</span></div>
					<div>
						<textarea id="appXml" style="font-size:11px; margin: 5px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto" wrap="off"></textarea>
					</div>
				</div>	
				<div id="appLibPropertyTab">
					<div style="margin-top:5px;text-align:right">
						<button id="refreshLibButton">refresh</button>
						<button id="addLibButton">add</button>
						<button id="removeLibButton">delete</button>
					</div>
					<div style="margin-top:5px;">
						<table id="appLibListTable"></table>
					</div>
				</div>				
				<div id="actionPropertyTab">
					<div style="margin-top:5px; margin-right:10px">
						<span style='display:inline-block; width:50px; margin-left:10px'>name:</span><input id="actionPropertyTab_itemName" style="width:150px" type="text" readonly="readonly"/>
						<input type="hidden" id="actionPropertyTab_itemId"/>
						<button id='itemXmlRefreshButton'>refresh</button>
						<button id='itemSettingButton'>Setting...</button>
					</div>
					<div>
						<textarea id="propertyXml" style="font-size:11px; margin: 5px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto;" wrap="off"></textarea>
					</div>
				</div>
			</div>
		</div>
	</div>	
</div>
<div style="visibility:hidden">
	<input type="hidden" id="currentConfigItemId"></input>
</div>
 
<div id="appLibSelectDialog" title="Select lib file">
	<div style="text-align:right">
		<button id="appLibSelectDialogAddFileButton">add file...</button>
	</div>
	<div>
		<table id="appLibSelectTable"></table>
	</div>
	<div style='margin-top:5px;'>
		<div id=appLibSelectDialog_queryDiv>
			<div><b>Query:</b></div>
			<textarea id="appLibSelectDialog_query" style="width:675px;height:170px; font-size:11px; margin-top:5px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto"></textarea>
		</div>
	</div>
</div>

<div id="appLibDialog" title="add lib file">
	<form id="appLibUploadForm" method="post" enctype="multipart/form-data" action="${ctx}/common/appLibUpload.do">
		<div style="margin-top:10px"><span style="display:inline-block;width:80px;text-align:right;">app name:</span><input type="text" id="libAppName" name="appName" readonly="readonly" style="width:450px"/></div>
		<div style="margin-top:5px"><span style="display:inline-block;width:80px;text-align:right;">is lib:</span><input type="checkbox" id="libYn" name="libYn" value="lib" checked="checked"/></div>
		<div style="margin-top:5px"><span style="display:inline-block;width:80px;text-align:right;">file:</span><input type="file" id="libFile" name="libFile"/></div>
	</form>
	<div id="libUploadMessage" style="margin-top:20px; text-align:center"></div>
</div>

<div id="map-reduceDialog">
	<div>
		<div style="margin-top:5px"><span style='display:inline-block; width:120px'>name:</span><input type='text' id='map-reduceDialog_name' style="width:635px"/></div>
		<div style="margin-top:5px">
			<div style='float:left;width:380px'>
				<span style='display:inline-block; width:120px'>job-tracker:</span><select style="width:260px" id="map-reduceDialog_jobtracker" onchange="$('#map-reduceDialog_jobtrackerText').val($(this).val());"></select>
				<input id="map-reduceDialog_jobtrackerText" style="margin-left: -260px; width: 240px; height: 1.3em; border: 0;" />
			</div>
			<div style='float:left;width:380px'>
				<span style='display:inline-block; width:80px;text-align:right'>name-node:</span><select style="width:260px" id="map-reduceDialog_namenode" onchange="$('#map-reduceDialog_namenodeText').val($(this).val());"></select>
				<input id="map-reduceDialog_namenodeText" style="margin-left: -260px; width: 240px; height: 1.3em; border: 0;" />
			</div>
			<div style='clear:both'></div>
		</div>
		<div style="margin-top:5px">
			<div>
				<span style='display:inline-block; width:120px'>prepare:</span>
				<select id="map-reduceDialog_prepareItem" style="width:150px">
					<option selected="selected">mkdir</option>
					<option>delete</option>
				</select>
				&nbsp;&nbsp;path: <input type="text" id="map-reduceDialog_preparePath" style="width:405px"/>&nbsp;
				<button id="addPrepareButton">add</button>
			</div>
			<div>
				<span style='display:inline-block; width:120px'></span>
				<textarea id="map-reduceDialog_prepare" style="width:600px;height:30px; font-size:11px; margin-top:5px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto"></textarea>
			</div>
		</div>
		<div style="margin-top:5px">
			<div>
				<div style='float:left'>
					<span style='display:inline-block; width:120px'>files:</span>
					<select id="map-reduceDialog_fileItem" style="width:150px">
						<option>archive</option>
						<option>file</option>
						<option selected="selected">job-xml</option>
					</select>
					&nbsp;&nbsp;path: <input type="text" id="map-reduceDialog_fileText" style="width:385px"/>&nbsp;
				</div>
				<div style='float:left'>
					<span class='ui-icon ui-icon-circle-zoomin' style='cursor:pointer;margin-top:3px' onclick='libSelectDialogParams=[["fileName","map-reduceDialog_fileText"]]; showLibSelectDialog(false);'></span>
				</div>
				<div style='float:left;margin-left:5px'>
					<button id="map-reduceFileButton">add</button>
				</div>
				<div style="clear:both"></div>
			</div>
			<div>
				<span style='display:inline-block; width:120px'></span>
				<textarea id="map-reduceDialog_file" style="width:600px;height:40px; font-size:11px; margin-top:5px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto"></textarea>
			</div>
		</div>
		<div style="margin-top:5px"><span style='display:inline-block; width:120px'>use new m/r api:</span><input type="checkbox"/>&nbsp;&nbsp;(not recommedned under ver hadoop-2.0)</div>
		<div style="margin-top:5px">
			<span style='display:inline-block; width:120px'>job type:</span><input type="radio" name="mapReduceJobType" value="normal" checked="checked"/> normal&nbsp;&nbsp;
			<input type="radio" name="mapReduceJobType" value="streaming"/> streaming&nbsp;&nbsp;
			<input type="radio" name="mapReduceJobType" value="pipe"/> pipe
		</div>
		<div style="margin-top:5px;">
			<div id="map-reduceDialog-tab">
				<ul>
					<li><a href="#map-reduceProperty"><span>Job Conf</span></a></li>
					<li><a href="#map-reduceStreaming"><span>Streaming</span></a></li>
					<li><a href="#map-reducePipe"><span>Pipe</span></a></li>
				</ul>
				<div id="map-reduceProperty">
					<div style="width:700px">
						<div style="margin-top:5px;">
							<div>
								<div style='float:left'>
									name: <input type="text" id="saveMapReducePropertyName" style="width:400px"/>
								</div>
								<div style='float:left'>
									<span class='ui-icon ui-icon-circle-zoomin' style='cursor:pointer;margin-top:3px' onclick='$("#jobPropertyDialog").dialog("open");'></span> 
								</div>
								<div style='clear:both'></div>
							</div>
							<div style="margin-top:5px;">
								<div style='float:left'>
									value: <input type="text" id="saveMapReducePropertyValue" style="width:400px"/>
								</div>
								<div style='float:left'>
									<span class='ui-icon ui-icon-circle-zoomin' style='cursor:pointer;margin-top:3px' onclick='showLibClassDialog("saveMapReducePropertyValue");'></span>
								</div>
								<div style='float:left; margin-left:10px'>
									<button id="newMapReducePropertyButton">new</button>
									<button id="saveMapReducePropertyButton">save</button>
									<button id="deleteMapReducePropertyButton">delete</button>
								</div>
								<div style='clear:both'></div>
							</div>
							<div style="width:700px; margin-top:5px;">
								<table id="mapReducePropertyTable"></table>
							</div>
						</div>
					</div>
				</div>			
				<div id="map-reduceStreaming">
					<textarea id="map-reduceStreamingXml" style="width:700px;height:250px; font-size:11px; margin: 5px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto"></textarea>
				</div>
				<div id="map-reducePipe">
					<textarea id="map-reducePipeXml" style="width:700px; height:250px; font-size:11px; margin: 5px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto"></textarea>
				</div>
			</div>
		</div>
	</div>
</div>

<div id="queryActionDialog">
	<div>
		<input type="hidden" id="queryActionDialog_prefix"></input>
		<div style="margin-top:5px"><span style='display:inline-block; width:70px; font-weight:bold'>name:</span><input type='text' id='queryActionDialog_name' style="width:695px"/></div>
		<div style="margin-top:5px">
			<div style='float:left;width:370px'>
				<span style='display:inline-block; width:70px; font-weight:bold'>job-tracker:</span><select style="width:290px" id="queryActionDialog_jobtracker" onchange="$('#queryActionDialog_jobtrackerText').val($(this).val());"></select>
				<input id="queryActionDialog_jobtrackerText" style="margin-left: -290px; width: 273px; height: 1.3em; border: 0;" />
			</div>
			<div style='float:left;width:370px'>
				<span style='display:inline-block; width:80px; font-weight:bold'>name-node:</span><select style="width:290px" id="queryActionDialog_namenode" onchange="$('#queryActionDialog_namenodeText').val($(this).val());"></select>
				<input id="queryActionDialog_namenodeText" style="margin-left: -290px; width: 273px; height: 1.3em; border: 0;" />
			</div>
			<div style='clear:both'></div>
		</div>
		<div style="margin-top:5px">
			<div>
				<div style='float:left; margin-top:5px'>
					<span style='display:inline-block; width:70px; font-weight:bold'>Query:</span>
				</div>
				<div style='float:left; margin-top:5px'>
					<span class='ui-icon ui-icon-circle-zoomin' style='cursor:pointer;' onclick='showHiveQueryDialog();'></span>
				</div>
				<div style='float:left; margin-top:5px'>
					(Search query in cloumon hive manager)
				</div>
				<div style='margin-left:30px; margin-top:2px; float:left'>
					Query file in hdfs: <input id="queryActionDialog_queryFile" type="text" style=width:300px;" value="script.q"/>
				</div>
				<div style='float:left'>
					<span class='ui-icon ui-icon-circle-zoomin' style='cursor:pointer;margin-top:3px' onclick='libSelectDialogParams=[["fileName","queryActionDialog_queryFile"], ["query", "queryActionDialog_query"]]; showLibSelectDialog();'></span>
				</div>
				<div style='clear:both'></div>
			</div>
			<div>
				<textarea id="queryActionDialog_query" style="width:775px;height:80px; font-size:11px; margin-top:5px; border: 1px solid #A6C9E2; border-radius:4px; overflow: auto"></textarea>
			</div>
		</div>
		<div style="padding:5px" class="ui-widget ui-widget-content ui-corner-all">
			<div>
				<b>Prepare:</b>
				<select id="queryActionDialog_prepareItem" style="width:150px">
					<option selected="selected">mkdir</option>
					<option>delete</option>
				</select>
				&nbsp;&nbsp;path: <input type="text" id="queryActionDialog_preparePath" style="width:450px"/>&nbsp;
				<button id="addQueryPrepareButton">add</button>
			</div>
			<div>
				<textarea id="queryActionDialog_prepare" style="width:750px;height:30px; font-size:11px; margin-top:5px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto"></textarea>
			</div>
		</div>
		<div style="padding:5px;margin-top:2px" class="ui-widget ui-widget-content ui-corner-all">
			<div>
				<div style='float:left'>
					<b>files:</b>
					<select id="queryActionDialog_fileItem" style="width:150px">
						<option selected="selected">archive</option>
						<option>file</option>
						<option>job-xml</option>
					</select>
					&nbsp;&nbsp;path: <input type="text" id="queryActionDialog_fileText" style="width:440px"/>&nbsp;
				</div>
				<div style='float:left'>
					<span class='ui-icon ui-icon-circle-zoomin' style='cursor:pointer;margin-top:3px' onclick='libSelectDialogParams=[["fileName","queryActionDialog_fileText"]]; showLibSelectDialog(false);'></span>
				</div>
				<div style='float:left;margin-left:5px'>
					<button id="queryActionFileButton">add</button>
				</div>
				<div style="clear:both"></div>
			</div>
			<div>
				<textarea id="queryActionDialog_file" style="width:750px;height:30px; font-size:11px; margin-top:5px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto"></textarea>
			</div>
		</div>
		<div style="padding:5px;margin-top:2px" class="ui-widget ui-widget-content ui-corner-all">
			<div>
				<b>Parameter:</b>
				<select id="queryActionDialog_paramItem" style="width:150px" onchange="$('#queryActionDialog_paramItemText').val($(this).val());">
					<option selected="selected"></option>
					<!-- 
					TODO find params from query(hive ${param_name}, pig $param_name
					 -->
				</select><input id="queryActionDialog_paramItemText" style="margin-left: -148px; width: 125px; height: 1.3em; border: 0;" /><span style='display:inline-block;margin-left:30px'>value: </span><input type="text" id="queryActionDialog_paramValue" style="width:390px"/>&nbsp;<button id="addQueryParamButton">add</button>
			</div>
			<div>
				<textarea id="queryActionDialog_param" style="width:750px;height:30px; font-size:11px; margin-top:5px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto"></textarea>
			</div>
		</div>
		<div style='margin-top:5px; font-weight:bold'>Configuration:</div>
		<div class="ui-widget ui-widget-content ui-corner-all" style="padding:5px">
			<div>
				<div style='float:left'>
					name: <input type="text" id="queryActionDialogPropertyName" style="width:200px"/>
				</div>
				<div style='float:left'>
					<span class='ui-icon ui-icon-circle-zoomin' style='cursor:pointer;margin-top:3px' onclick='actionPropertyReturnPrefix="queryAction"; $("#actionPropertyDialog").dialog("open");'></span> 
				</div>
				<div style='float:left;margin-left:30px'>
					value: <input type="text" id="queryActionDialogPropertyValue" style="width:200px"/>
					&nbsp;<button id="newQueryActionPropertyButton">new</button>
					<button id="saveQueryActionPropertyButton">save</button>
					<button id="deleteQueryActionPropertyButton">delete</button>
				</div>
				<div style='clear:both'></div>
			</div>
			<div style="width:720px; margin-top:5px;">
				<table id="queryActionDialogPropertyTable"></table>
			</div>
		</div>
	</div>
</div>

<div id="javaDialog">
	<div>
		<div style="margin-top:5px"><span style='display:inline-block; width:120px'>name:</span><input type='text' id='javaDialog_name' style="width:635px"/></div>
		<div style="margin-top:5px">
			<div style='float:left;width:380px'>
				<span style='display:inline-block; width:120px'>job-tracker:</span><select style="width:260px" id="javaDialog_jobtracker" onchange="$('#javaDialog_jobtrackerText').val($(this).val());"></select>
				<input id="javaDialog_jobtrackerText" style="margin-left: -260px; width: 240px; height: 1.3em; border: 0;" />
			</div>
			<div style='float:left;width:380px'>
				<span style='display:inline-block; width:80px;text-align:right'>name-node:</span><select style="width:260px" id="javaDialog_namenode" onchange="$('#javaDialog_namenodeText').val($(this).val());"></select>
				<input id="javaDialog_namenodeText" style="margin-left: -260px; width: 240px; height: 1.3em; border: 0;" />
			</div>
			<div style='clear:both'></div>
		</div>
		<div style="margin-top:5px">
			<div style='float:left'><span style='display:inline-block; width:120px'>main class:</span><input type='text' id='javaDialog_mainClass' style="width:590px"/></div>
			<div style='float:left'><span class='ui-icon ui-icon-circle-zoomin' style='cursor:pointer;margin-top:3px' onclick='showLibClassDialog("javaDialog_mainClass");'></span> </div>
			<div style='clear:both'></div>
		</div>
		<div style="margin-top:5px"><span style='display:inline-block; width:120px'>java-opts:</span><input type='text' id='javaDialog_javaOpts' style="width:635px"/></div>
		<div style="margin-top:5px"><span style='display:inline-block; width:120px'>capture-oupput:</span><input id="javaDialog_captureOutput" type="checkbox"/></div>
		<div style="padding:5px;margin-top:10px" class="ui-widget ui-widget-content ui-corner-all">
			<div>
				<b>Arguments:</b>
				<input type="text" id="javaDialog_argsText" style="width:490px"/>&nbsp;<button id="addJavaArgsButton">add</button>
			</div>
			<div>
				<textarea id="javaDialog_args" style="width:750px;height:70px; font-size:11px; margin-top:5px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto"></textarea>
			</div>
		</div>
		<div style="padding:5px;margin-top:2px" class="ui-widget ui-widget-content ui-corner-all">
			<div>
				<div style='float:left'>
					<b>files:</b>
					<select id="javaDialog_fileItem" style="width:150px">
						<option selected="selected">archive</option>
						<option>file</option>
						<option>job-xml</option>
					</select>
					&nbsp;&nbsp;path: <input type="text" id="javaDialog_fileText" style="width:440px"/>&nbsp;
				</div>
				<div style='float:left'>
					<span class='ui-icon ui-icon-circle-zoomin' style='cursor:pointer;margin-top:3px' onclick='libSelectDialogParams=[["fileName","javaDialog_fileText"]]; showLibSelectDialog(false);'></span>
				</div>
				<div style='float:left;margin-left:5px'>
					<button id="javaFileButton">add</button>
				</div>
				<div style="clear:both"></div>
			</div>
			<div>
				<textarea id="javaDialog_file" style="width:750px;height:30px; font-size:11px; margin-top:5px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto"></textarea>
			</div>
		</div>
		<div style='margin-top:5px; font-weight:bold'>Configuration:</div>
		<div class="ui-widget ui-widget-content ui-corner-all" style="padding:5px">
			<div>
				<div style='float:left'>
					name: <input type="text" id="javaDialogPropertyName" style="width:200px"/>
				</div>
				<div style='float:left'>
					<span class='ui-icon ui-icon-circle-zoomin' style='cursor:pointer;margin-top:3px' onclick='actionPropertyReturnPrefix="java"; $("#actionPropertyDialog").dialog("open");'></span> 
				</div>
				<div style='float:left;margin-left:30px'>
					value: <input type="text" id="javaDialogPropertyValue" style="width:200px"/>
					&nbsp;<button id="newJavaPropertyButton">new</button>
					<button id="saveJavaPropertyButton">save</button>
					<button id="deleteJavaPropertyButton">delete</button>
				</div>
				<div style='clear:both'></div>
			</div>
			<div style="width:720px; margin-top:5px;">
				<table id="javaDialogPropertyTable"></table>
			</div>
		</div>
	</div>
</div>

<div id="userDefineDialog">
	<div>
		<div style="margin-top:5px"><span style='display:inline-block; width:120px'>name:</span><input type='text' id='userDefineDialog_name' style="width:635px"/></div>
		<div style='margin-top:5px; font-weight:bold'>Action XML:</div>
		<div style="padding:5px" class="ui-widget ui-widget-content ui-corner-all">
			<div>
				<textarea id="userDefineDialog_actionXml" style="width:750px;height:300px; font-size:11px; margin-top:5px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto"></textarea>
			</div>
		</div>
	</div>
</div>

<div id="actionPropertyDialog" title="Configuration properies">
	<div>
		<table id="actionDefaultPropertyTable"></table>
	</div>
</div>

<div id="hiveQueryDialog" title="Hive query">
	<div>
		<table id="hiveQueryTable"></table>
	</div>
	<div style='margin-top:5px;'>
		<div><b>Query:</b></div>
		<textarea id="hiveQueryDialog_query" style="width:675px;height:170px; font-size:11px; margin-top:5px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto"></textarea>
	</div>
</div>

<div id="jobPropertyDialog" title="Job configuration properies">
	<div>
		<table id="jobDefaultPropertyTable"></table>
	</div>
</div>

<div id="jobLibClassListDialog" title="Library classes">
	<div>
		<div>
			lib files: <select id="jobLibClassLibFiles"></select> &nbsp;&nbsp;&nbsp;
			class type: <select id="jobLibClassType"></select>
			<button id="uploadAppLibButton">add lib file</button>
		</div>
		<div style="margin-top:5px">
			<table id="jobLibClassListTable"></table>
		</div>
		<input type="hidden" id="jobLibClassListDialog_returnId"/>
	</div>
</div>

<div id="sshDialog">
	<div>
		<div style="margin-top:5px"><span style='display:inline-block; width:120px'>name:</span><input type='text' id='sshDialog_name' style="width:400px"/></div>
		<div style="margin-top:5px"><span style='display:inline-block; width:120px'>host:</span><input type='text' id='sshDialog_host' style="width:400px"/></div>
		<div style="margin-top:5px"><span style='display:inline-block; width:120px'>command:</span><input type='text' id='sshDialog_command' style="width:400px"/></div>
		<div style="margin-top:5px"><span style='display:inline-block; width:120px'>capture-output:</span><input id="sshDialog_captureOutput" type="checkbox"/></div>
		<div style='margin-top:5px; font-weight:bold'>Args:</div>
		<div style="padding:5px" class="ui-widget ui-widget-content ui-corner-all">
			<div>
				<input type="text" id="sshDialog_argsText" style="width:300px"/>&nbsp;<button id="addSshArgsButton">add</button>
			</div>
			<div>
				<textarea id="sshDialog_args" style="width:515px;height:70px; font-size:11px; margin-top:5px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto"></textarea>
			</div>
		</div>
	</div>
</div>

<div id="shellDialog">
	<div>
		<div style="margin-top:5px"><span style='display:inline-block; width:120px'>name:</span><input type='text' id='shellDialog_name' style="width:635px"/></div>
		<div style="margin-top:5px">
			<div style='float:left;width:380px'>
				<span style='display:inline-block; width:120px'>job-tracker:</span><select style="width:260px" id="shellDialog_jobtracker" onchange="$('#shellDialog_jobtrackerText').val($(this).val());"></select>
				<input id="shellDialog_jobtrackerText" style="margin-left: -260px; width: 240px; height: 1.3em; border: 0;" />
			</div>
			<div style='float:left;width:380px'>
				<span style='display:inline-block; width:80px;text-align:right'>name-node:</span><select style="width:260px" id="shellDialog_namenode" onchange="$('#shellDialog_namenodeText').val($(this).val());"></select>
				<input id="shellDialog_namenodeText" style="margin-left: -260px; width: 240px; height: 1.3em; border: 0;" />
			</div>
			<div style='clear:both'></div>
		</div>
		<div style="margin-top:5px"><span style='display:inline-block; width:120px'>exec:</span><input type='text' id='shellDialog_exec' style="width:635px"/></div>
		<div style="margin-top:5px"><span style='display:inline-block; width:120px'>capture-oupput:</span><input id="shellDialog_captureOutput" type="checkbox"/></div>
		<div style='margin-top:5px;font-weight:bold'>Prepare:</div>
		<div style="padding:5px" class="ui-widget ui-widget-content ui-corner-all">
			<div>
				<select id="shellDialog_prepareItem" style="width:150px">
					<option selected="selected">mkdir</option>
					<option>delete</option>
				</select>
				&nbsp;&nbsp;path: <input type="text" id="shellDialog_preparePath" style="width:490px"/>&nbsp;
				<button id="addShellPrepareButton">add</button>
			</div>
			<div>
				<textarea id="shellDialog_prepare" style="width:750px;height:30px; font-size:11px; margin-top:5px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto"></textarea>
			</div>
		</div>
		<div style='margin-top:5px; font-weight:bold'>Arguments:</div>
		<div style="padding:5px" class="ui-widget ui-widget-content ui-corner-all">
			<div>
				<input type="text" id="shellDialog_argumentText" style="width:490px"/>&nbsp;<button id="addShellArgsButton">add</button>
			</div>
			<div>
				<textarea id="shellDialog_argument" style="width:750px;height:40px; font-size:11px; margin-top:5px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto"></textarea>
			</div>
		</div>
		<div style='margin-top:5px; font-weight:bold'>Env variables:</div>
		<div style="padding:5px" class="ui-widget ui-widget-content ui-corner-all">
			<div>
				<input type="text" id="shellDialog_envVarNameText" style="width:200px"/> = <input type="text" id="shellDialog_envVarValueText" style="width:200px"/>&nbsp;<button id="addShellEnvVarButton">add</button>
			</div>
			<div>
				<textarea id="shellDialog_envVar" style="width:750px;height:30px; font-size:11px; margin-top:5px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto"></textarea>
			</div>
		</div>
		<div style='margin-top:5px; font-weight:bold'>Configuration:</div>
		<div class="ui-widget ui-widget-content ui-corner-all" style="padding:5px">
			<div>
				<div style='float:left'>
					name: <input type="text" id="shellDialogPropertyName" style="width:200px"/>
				</div>
				<div style='float:left'>
					<span class='ui-icon ui-icon-circle-zoomin' style='cursor:pointer;margin-top:3px' onclick='actionPropertyReturnPrefix="shell"; $("#actionPropertyDialog").dialog("open");'></span> 
				</div>
				<div style='float:left;margin-left:30px'>
					value: <input type="text" id="shellDialogPropertyValue" style="width:200px"/>
					&nbsp;<button id="newShellPropertyButton">new</button>
					<button id="saveShellPropertyButton">save</button>
					<button id="deleteShellPropertyButton">delete</button>
				</div>
				<div style='clear:both'></div>
			</div>
			<div style="width:720px; margin-top:5px;">
				<table id="shellDialogPropertyTable"></table>
			</div>
		</div>
	</div>
</div>

<div id="fsDialog">
	<div>
		<div style="margin-top:5px;"><span style='display:inline-block; width:80px; text-align:left'>name:</span><input type='text' id='fsDialog_name' style="width:480px"/></div>
		<div style="margin-top:5px;"><span style='display:inline-block; width:80px; text-align:left'>operation:</span>
			<select id="fsDialog_operation">
				<option value=""></option>
				<option value="delete">delete</option>
				<option value="mkdir">mkdir</option>
				<option value="move">move</option>
				<option value="chmod">chmod</option>
			</select>
			<button id="fsDialogAddButton">add operation</button>
		</div>
		<div style='margin-top:5px; font-weight:bold'>Attributes:</div>
		<div class="ui-widget ui-widget-content ui-corner-all" style='width:560px;height:80px;padding:5px 0px 5px 5px'>
			<div id="fsDialog_deleteDiv">
				<div style="margin-top:5px;"><span style='display:inline-block; width:80px; text-align:left'>path:</span><input type='text' id='fsDialog_path' style="width:460px"/></div>
			</div>
			<div id="fsDialog_moveDiv">
				<div style="margin-top:5px;"><span style='display:inline-block; width:80px; text-align:left'>source:</span><input type='text' id='fsDialog_source' style="width:460px"/></div>
				<div style="margin-top:5px;"><span style='display:inline-block; width:80px; text-align:left'>target:</span><input type='text' id='fsDialog_target' style="width:460px"/></div>
			</div>
			<div id="fsDialog_chmodDiv">
				<div style="margin-top:5px;"><span style='display:inline-block; width:80px; text-align:left'>path:</span><input type='text' id='fsDialog_chmodPath' style="width:460px"/></div>
				<div style="margin-top:5px;"><span style='display:inline-block; width:80px; text-align:left'>permissions:</span><input type='text' id='fsDialog_permissions' style="width:460px"/></div>
				<div style="margin-top:5px;"><span style='display:inline-block; width:80px; text-align:left'>dir-files:</span><input type='checkbox' id='fsDialog_dirFiles'/></div>
			</div>
		</div>
		<div style="margin-top:10px">
			<div style='text-align:right;margin-right:30px'><button id="fsDialogDeleteButton">delete</button></div>
			<table id="fsDialogCommandTable"></table>
		</div>		
	</div>
</div>
<div id="endDialog" title="end">
	<div>
		<div style="margin-top:5px"><span style='display:inline-block; width:40px'>name:</span><input type='text' id='endDialog_name' style="width:300px"/></div>
	</div>
</div>

<div id="killDialog" title="kill">
	<div>
		<div style="margin-top:5px"><span style='display:inline-block; width:60px'>name:</span><input type='text' id='killDialog_name' style="width:330px"/></div>
		<div style="margin-top:5px">
			<div><span style='display:inline-block; width:60px'>message:</span><input type='text' id='killDialog_message' style="width:330px"/></div>
			<div><span style='display:inline-block; width:60px'></span>ex) job failed, error message[&#36;{wf&#58;errorMessage(wf&#58;lastErrorNode())}]</div>
		</div>
	</div>
</div>

<div id="decisionDialog" title="decision">
	<div>
		<div style="margin-top:5px"><span style='display:inline-block; width:60px'>name:</span><input type='text' id='decisionDialog_name' style="width:500px"/></div>
		<div style="margin-top:5px"><b>Add switch case</b></div>
		<div style="margin-top:10px"><span style='display:inline-block; width:60px'>condition:</span><input type="text" id="decisionDialog_condition" style="width:400px"/>
			<button id="wfHelpButton" onclick="$('#elFunctionResultField').val('decisionDialog_condition'); $('#elFunctionDialog').dialog('open');">function help</button>
		</div>
		<div style="margin-top:5px"><span style='display:inline-block; width:60px'>default:</span><input type="checkbox" id="decisionDialog_default"/></div>
		<div style="margin-top:5px"><span style='display:inline-block; width:60px'>to:</span><select id="decisionDialog_caseTo"></select>
			<button id="addSwitchCaseButton">add case</button>
			<button id="deleteSwitchCaseButton">delete case</button>
		</div>
		<div>
			<table id="decisionCaseTable"></table>
		</div>
	</div>
</div>

<div id="decisionConditionDialog" title="Decision condition">
	<div>
		<input type='hidden' id='decisionConditionDialog_sourceId'/>
		<input type='hidden' id='decisionConditionDialog_targetId'/>
		<div style="margin-top:10px"><span style='display:inline-block; width:60px'>condition:</span><input type="text" id="decisionConditionDialog_condition" style="width:400px"/>
			<button id="wfHelpButton" onclick="$('#elFunctionResultField').val('decisionConditionDialog_condition'); $('#elFunctionDialog').dialog('open');">function help</button>
		</div>
	</div>
</div>

<div id="newAppDialog" title="New Application">
	<div>
		<div style="margin-top:5px"><span style='display:inline-block; width:40px'>name:</span><input type='text' id='newAppDialog_name' style="width:330px"/></div>
	</div>
</div>

<div id="elFunctionDialog" title="El Functions">
	<div>
		<input type="hidden" id="elFunctionResultField"/>
		<table id="elFunctionTable"></table>
	</div>
</div>

<div id="forkDialog" title="fork">
	<div>
		<div style="margin-top:5px"><span style='display:inline-block; width:60px'>name:</span><input type='text' id='forkDialog_name' style="width:330px"/></div>
	</div>
</div>

<div id="joinDialog" title="join">
	<div>
		<div style="margin-top:5px"><span style='display:inline-block; width:60px'>name:</span><input type='text' id='joinDialog_name' style="width:330px"/></div>
	</div>
</div>
<%@ include file="./common_dialog.jsp"%>
</body>
</html>