<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" style="overflow: hidden">
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

</style>

<script type="text/javascript">
//http://stackoverflow.com/questions/5611065/adding-new-row-to-jqgrid-using-modal-form-on-client-only

var leftLength = 400;

var tableMargins = {'centerTopPane': 90, 'centerCenterPane': 90};

function resizeLayout(event, container) {
	$("#appListTable").setGridWidth($("#westPane").width() - 22);
	$("#appListTable").setGridHeight($("#westPane").height() - 140 - 330);

	$("#appXml").css( {width: ($("#westPane").width() - 22) + 'px', height: '300px'} );
	
	$("#scheduleJobTable").setGridWidth($("#centerTopPane").width() - 22);
	$("#scheduleJobTable").setGridHeight($("#centerTopPane").height() - 93);

	$("#jobHistoryTable").setGridWidth($("#centerCenterPane").width() - 22);
	$("#jobHistoryTable").setGridHeight($("#centerCenterPane").height() - 93);
}

$(document).ready(function() {
	//workflowUtil.initAppListTable("appListTable", leftLength - 5, 250, appSelected);
	workflowUtil.initAppListTable("appListTable", 500, 200, appSelected);
	workflowUtil.loadAppListTable("appListTable");

	$("#scheduleDetail").accordion();
	
	$("#jobHistoryFromTime").val((new Date()).format("yyyy-mm-dd"));
	$("#jobHistoryToTime").val((new Date()).format("yyyy-mm-dd"));
	
	$("#jobHistoryFromTime").datepicker({ dateFormat: "yy-mm-dd", autoSize: true, gotoCurrent: true, buttonImage: "/images/datepicker.gif"  });
	$("#jobHistoryToTime").datepicker({ dateFormat: "yy-mm-dd", autoSize: true, gotoCurrent: true, buttonImage: "/images/datepicker.gif"  });
	$("#jobPropertyTab").tabs();
	
	$("#scheduleJobTable").jqGrid({
		datatype: "local",
		rowNum: 100000,
	   	colNames:['Job Name', 'Workflow App', 'Schedule', 'Last JobId', 'Last Status', 'Last Execution', 'User', 'Description', 'jobParamMap', 'mailTo', 'mailOnlyFail'],
	   	colModel:[
	   		{name:'jobName',index:'jobName', width:70, sortable:true},
	   		{name:'appName',index:'appName', width:70, sortable:true},
	   		{name:'scheduleInfo',index:'scheduleInfo', width:80, sortable:false},
	   		{name:'lastJobId',index:'lastJobId', width:100, sortable:false},
	   		{name:'lastStatus',index:'lastStatus', width:100, sortable:false},
	   		{name:'lastExecutionTime',index:'lastExecutionTime', width:100, sortable:true, 
	   			formatter: function(cellvalue, options, rowObject) {
	   				if(cellvalue == 0 || cellvalue == null) {
		   				return "-";
	   				} else {
	   					return (new Date(cellvalue)).format("yyyy-mm-dd HH:MM:ss");
	   				}
	   		} },
	   		{name:'userName',index:'userName', width:90, sortable: true},
	   		{name:'description',index:'description', width:90, sortable: false, hidden: true},
	   		{name:'jobParamMap', index:'jobParamMap', hidden: true, editable: false,  editrules: {edithidden:true} }, 
	   		{name:'mailTo', index:'mailTo', hidden: true, editable: false,  editrules: {edithidden:true} }, 
	   		{name:'mailOnlyFail', index:'mailOnlyFail', hidden: true, editable: false,  editrules: {edithidden:true} } 
	   	],
		onSelectRow: function(jobName){
			$("#jobHistoryJobName").val(jobName);
			$("#jobHistoryButton").click();
		},
		ondblClickRow: function(rowid, ri, ci) {
			editJob();
		}
	});

	$("#jobHistoryTable").jqGrid({
		datatype: "local",
		//height: 300,
		//width: 300,
		rowNum: 100000,
	   	colNames:['app name', 'id', 'status', 'created', 'start', 'end', 'last modified', 'user', 'group', 'conf', 'app path', 'parent id'],
	   	colModel:[
	   		{name:'jobName',index:'jobName', width:200, sortable:true},
	   		{name:'id',index:'id', width:250, sortable:false},
	   		{name:'status',index:'status', width:70, sortable:true},
	   		{name:'createdTime',index:'createdTime', width:150, sortable:true, formatter: dateFormatter},
	   		{name:'startTime',index:'startTime', width:150, sortable:false, formatter: dateFormatter},
	   		{name:'endTime',index:'endTime', width:150, sortable:false, formatter: dateFormatter},
	   		{name:'lastModifiedTime',index:'lastModifiedTime', width:150, sortable:false, formatter: dateFormatter, hidden: true},
	   		{name:'user',index:'user', width:70, sortable:false},
	   		{name:'group',index:'group', width:70, sortable:false, hidden: true},
	   		{name:'conf',index:'conf', width:70, sortable:false, hidden: true},
	   		{name:'appPath',index:'appPath', width:70, sortable:false, hidden: true},
	   		{name:'parentId',index:'parentId', width:70, sortable:false, hidden: true}
	   	],
		ondblClickRow: function(rowid, ri, ci) {
			workflowUtil.showJobDetailView(rowid);
		}
	});

	$("#jobPropertiesTable").jqGrid({
		datatype: "local",
		height: 190,
		width: 650,
		rowNum: 100000,
        rowList:[5,10,20],
		cellsubmit: 'clientArray',
		editurl: APPLICATION_CONTEXT + 'workflow/dummy.do',
	   	colNames:['name', 'value'],
	   	colModel:[
	   		{ name:'name',index:'name', width:250, sortable:false, editable: true, editrules:{required:true} },
	   		{ name:'value',index:'value', width:400, sortable:false, editable: true, editrules:{required:true} }
	   	],
		onSelectRow: function(name){
		},
		ondblClickRow: function(rowid, ri, ci) {
			$("#modifyPropertyButton").click();
		}
	});

	$('#jobDetailDialog').dialog({ 
		width: 700, height: 600, modal: true, autoOpen: false,
		title: 'Job detail',
		buttons: [{
			text: "Save",
			click: function() {
				saveJob();
			}
		}, {
        	text: "Close",
            click: function() {
            	$(this).dialog("close");
            }
		}]
	});

	$('#scheduleSettingDialog').dialog({ 
		width: 600, height: 500, modal: true, autoOpen: false,
		title: 'Setting schedule',
		buttons: [{ 
			text: "Ok",
			click: function() {
				$("#scheduleTime").val($("#scheduleSettingTime").val());
    	    	$(this).dialog("close");
			}
		}, {
        	text: "Close",
            click: function() {
            	$(this).dialog("close");
            }
		}]
	});	

	$("#saveAppButton").click(function() {
		var appName = $("#appListTable").jqGrid('getGridParam', 'selrow');
		if(appName == null || appName == "") {
			alert("select workflow app.");
			return;
		}
		var xml = $("#appXml").val();
		if(xml == null || xml == "") {
			alert("no xml");
		}
		if(!confirm("saving application xml[" + appName + "]")) {
			return;
		}
		$.ajax({
			url: APPLICATION_CONTEXT + 'workflow/saveQuery.do', 
			type: 'POST',
			async: false,
			data: { appName: appName, queryFile: 'workflow.xml', query: xml },
			success: function(result) {
				if(!result.success) {
					alert(result.msg);
					return;
				} else {
					alert("Successfully saved");
				}
			}
		});	
		
	});
	
	$("#newInstanceButton").click(function() {
		var appName = $("#appListTable").jqGrid('getGridParam', 'selrow');
		if(appName == null || appName == "") {
			alert("select workflow app.");
			return;
		}
		var selectedRecord = workflowUtil.getTableData("appListTable", appName);
		
		$.ajax({
			url: APPLICATION_CONTEXT + 'workflow/findProperty.do', 
			type: 'POST',
			async: false,
			data: { xml: selectedRecord.xml },
			success: function(result) {
				if(!result.success) {
					alert(result.msg);
					return;
				} else {
					$("#jobDetailAppName").val(appName);

					$("#jobPropertiesTable").jqGrid("clearGridData");
					for(var i = 0; i < result.data.length; i++) {
						var recordData = { name: result.data[i], value: ""};
						$("#jobPropertiesTable").jqGrid('addRowData', result.data[i],recordData);
					}
					$("#jobDetailXml").val(selectedRecord.xml);
					$('#jobDetailDialog').dialog('open');
				}
			}
		});	
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
	
	$("#jobLogRefreshButton").click(function() {
		showJobLog();
	});
	
	$("#scheduleSettingButton").click(function() {
		$("#scheduleSettingDialog").dialog("open");
	});

	$("#schedule-time-every-minute").change(function() {
		setScheduleTime('minute', 1);
	});
	$("#schedule-time-every-n-minute").change(function() {
		setScheduleTime('minute', 2);
	});
	$("#schedule-time-selected-minute").change(function() {
		setScheduleTime('minute', 3);
	});

	$("#schedule-time-every-hour").change(function() {
		setScheduleTime('hour', 1);
	});
	$("#schedule-time-every-n-hour").change(function() {
		setScheduleTime('hour', 2);
	});
	$("#schedule-time-selected-hour").change(function() {
		setScheduleTime('hour', 3);
	});

	$("#schedule-time-every-day").change(function() {
		setScheduleTime('dayofmonth', 1);
	});
	$("#schedule-time-selected-day").change(function() {
		setScheduleTime('dayofmonth', 2);
	});

	$("#schedule-time-every-month").change(function() {
		setScheduleTime('month', 1);
	});
	$("#schedule-time-selected-month").change(function() {
		setScheduleTime('month', 2);
	});

	$("#schedule-time-every-week").change(function() {
		setScheduleTime('week', 1);
	});
	
	for(var i = 0; i < 7; i++) {
		$("#schedule-time-selected-week" + i).change(function() {
			setScheduleTime('week', 2);
		});
	}

	$("#addPropertyButton").click(function() {
		var editSettings = {
			jqModal:false,
        	reloadAfterSubmit:false,
        	closeOnEscape:true,
        	savekey: [true,13],
        	closeAfterAdd: true,
        	addCaption: "Add Property", bSubmit: "Ok", bCancel: "Cancel",
        	afterSubmit: function(options, postdata) {
				var gridData = $("#jobPropertiesTable")[0].p.data;
				for(var i = 0; i < gridData.length; i++) {
					if(gridData[i].name == postdata.name) {
						return [false, postdata.name + " already exists property"];
					}
				}
				return [true];
			}
		};
		
		$("#jobPropertiesTable").jqGrid('editGridRow',"new", editSettings);
		$("#FrmGrid_jobPropertiesTable input[name=name]").attr("readonly", false);
	});

	$("#modifyPropertyButton").click(function() {
		var name = $("#jobPropertiesTable").jqGrid('getGridParam', 'selrow');

		if(name == null || name == "") {
			alert("select property");
			return;
		}
		
		var editSettings = {
			jqModal:false,
        	reloadAfterSubmit:false,
        	closeOnEscape:true,
        	savekey: [true,13],
        	closeAfterEdit:true,
        	addCaption: "Edit Property", bSubmit: "Ok", bCancel: "Cancel"
		};
		
		$("#jobPropertiesTable").jqGrid('editGridRow', name, editSettings);
		$("#FrmGrid_jobPropertiesTable input[name=name]").attr("readonly", true);
	});
	
	$("#removePropertyButton").click(function() {
		var name = jQuery("#jobPropertiesTable").jqGrid('getGridParam', 'selrow');

		if(name == null || name == "") {
			alert("select property");
			return;
		}

		$('#jobPropertiesTable').jqGrid('delRowData', name);
	});

	$("#runJobNowButton").click(function() {
		runJobNow();
	});

	$("#jobDetailButton").click(function() {
		editJob();
	});
	
	$("#jobHistoryButton").click(function() {
		getJobHistory();
	});

	$("#jobDeleteButton").click(function() {
		deleteJob();
	});

	$("#refreshJobButton").click(function() {
		getJobList();
	});

	$("#refreshAppButton").click(function() {
		workflowUtil.loadAppListTable("appListTable");
	});

	$("#editAppButton").click(function() {
		var appName = $("#appListTable").jqGrid("getGridParam", "selrow");
		if(appName == null || appName == "") {
			alert("select applicaiton.");
			return;
		}
		document.location.href = APPLICATION_CONTEXT + "workflow/workflowFrame.do?editAppName=" + appName;
	});
	
	$("#deleteAppButton").click(function() {
		workflowUtil.deleteApp('appListTable', function(appName) {
			alert(appName + " removed");
			workflowUtil.loadAppListTable("appListTable");
			$("#appXml").val('');
		});
	});

	$("#jobHistoryDetailButton").click(function() {
		var jobId = $("#jobHistoryTable").jqGrid("getGridParam", "selrow");
		workflowUtil.showJobDetailView(jobId);	
	});
	
	$("#killJobButton").click(function() {
		doJobOperation("kill");
	});
	
	$("#suspendJobButton").click(function() {
		doJobOperation("suspend");
	});

	$("#resumeJobButton").click(function() {
		doJobOperation("resume");
	});
	
	getJobList();

	$('#layout-container').layout({
		center: {
			paneSelector: '#centerPane',
			closable: false,
			resizable: false,
			slidable: false,
	    	childOptions: {
    			north: {
					paneSelector: '#centerTopPane',
					size: 262,
					onresize: resizeLayout,
			    	triggerEventsOnLoad: true
				},
				center: {
					paneSelector: '#centerCenterPane',
					closable: false,
					resizable: false,
					slidable: false,
					onresize: resizeLayout,
			    	triggerEventsOnLoad: true
				}
			}
	  	},
	  	west: {
	  		paneSelector: '#westPane',
	    	fxName: "slide",
	    	size:    450,
	    	maxSize: 600,
			onresize: resizeLayout,
	    	triggerEventsOnLoad: true  // resize the grin on load also
	  	}
	});
});

function doJobOperation(operation) {
	var jobId = jQuery("#jobHistoryTable").jqGrid('getGridParam', 'selrow');

	if(jobId == null || jobId == "") {
		alert("select job");
		return;
	}

	if(!confirm(operation + '[' + jobId + "]?")) {
		return;
	}
	
	$.ajax({
		url: APPLICATION_CONTEXT + 'workflow/' + operation + 'Job.do', 
		type: 'GET',
		async: false,
		data: { jobId: jobId },
		success: function(result) {
			if(!result.success) {
				alert(result.msg);
				return;
			} else {
				alert(jobId + " " + operation + "ed");
				$("#jobHistoryButton").click();
			}
		}
	});	
}

function deleteJob() {
	var jobName = jQuery("#scheduleJobTable").jqGrid('getGridParam', 'selrow');

	if(jobName == null || jobName == "") {
		alert("select job");
		return;
	}

	if(!confirm("Deleting " + jobName + "?")) {
		return;
	}

	$.ajax({
		url: APPLICATION_CONTEXT + 'workflow/deleteJob.do', 
		type: 'GET',
		async: false,
		data: { jobName: jobName },
		success: function(result) {
			if(!result.success) {
				alert(result.msg);
				return;
			} else {
				alert(jobName + " deleted");
				getJobList();
			}
		}
	});
}

function editJob() {
	var jobName = jQuery("#scheduleJobTable").jqGrid('getGridParam', 'selrow');

	if(jobName == null || jobName == "") {
		alert("select job");
		return;
	}
	var jobInfo = workflowUtil.getTableData('scheduleJobTable', jobName);

	$("#jobDetailAppName").val(jobInfo.appName);
	$("#jobDetailJobName").val(jobInfo.jobName);
	$("#jobDetailUserName").val(jobInfo.userName);
	$("#jobDetailMailTo").val(jobInfo.mailTo);
	$("#jobDetailMailOnlyFail").css('checked', jobInfo.mailOnlyFail == "Y");
	$("#scheduleTime").val(jobInfo.scheduleInfo);
	$("#jobDetailDescription").val(jobInfo.description);

	var jobParams = jobInfo.jobParamMap;

	$("#jobPropertiesTable").jqGrid("clearGridData");
	for (name in jobParams) {
		var recordData = { name: name, value: eval("jobParams." + name)};
		$("#jobPropertiesTable").jqGrid('addRowData', name, recordData);
	}

	$.ajax({
		url: APPLICATION_CONTEXT + 'workflow/getJob.do', 
		type: 'GET',
		async: false,
		data: { jobName: jobInfo.jobName },
		success: function(result) {
			if(!result.success) {
				alert(result.msg);
				return;
			} else {
				$('#jobDetailXml').val(result.data.xml);
				$('#jobDetailDialog').dialog('open');
			}
		}
	});	
}

function getJobHistory() {
	var jobName = $("#jobHistoryJobName").val();
	var from = $("#jobHistoryFromTime").val();
	var to = $("#jobHistoryToTime").val();
	
	$.ajax({
		url: APPLICATION_CONTEXT + 'workflow/getJobHistory.do', 
		type: 'GET',
		async: false,
		data: {
			jobName: jobName, from: from, to: to
		},
		success: function(result) {
			if(!result.success) {
				alert(result.msg);
				return;
			} else {
				$("#jobHistoryTable").jqGrid("clearGridData");
				for(var i = 0; i < result.data.length; i++) {
					var job = result.data[i];
					
					$("#jobHistoryTable").jqGrid('addRowData', job.id, job);
				}
			}
		}
	});	
}

function runJobNow() {
	var jobName = jQuery("#scheduleJobTable").jqGrid('getGridParam', 'selrow');

	if(jobName == null || jobName == "") {
		alert("select job");
		return;
	}
	if(!confirm("Run " + jobName + " now?")) {
		return;
	}

	$.ajax({
		url: APPLICATION_CONTEXT + 'workflow/runJob.do', 
		type: 'POST',
		async: false,
		data: { 
			jobName: jobName
		},
		success: function(result) {
			if(!result.success) {
				alert(result.msg);
				return;
			} else {
				alert(result.data + " executed");
				getJobList();
				getJobHistory();
			}
		}
	});	
}

function saveJob() {
	var appName = $("#jobDetailAppName").val();
	var jobName = $("#jobDetailJobName").val();
	var userName = $("#jobDetailUserName").val();
	var mailTo = $("#jobDetailMailTo").val();
	var mailOnlyFail = $("#jobDetailMailOnlyFail").attr('checked') == 'checked' ? 'Y' : 'N';
	var scheduleInfo = $("#scheduleTime").val();
	var description = $("#jobDetailDescription").val();

	if(appName == null || appName == "") {
		alert("No app name");
		return;
	}

	if(jobName == null || jobName == "") {
		alert("No job name");
		return;
	}

	if(scheduleInfo == null || scheduleInfo == "") {
		alert("No schedule info.");
		return;
	}

	if(userName == null || userName == "") {
		alert("No user name");
		return;
	}
	
	var propertyData = $("#jobPropertiesTable")[0].p.data;
	var jobParams = '{';
	var delim = "";
	for(var i = 0; i < propertyData.length; i++) {
		jobParams += delim + '"' + propertyData[i].name + '":"' + propertyData[i].value + '"';
		if(propertyData[i].value == null || propertyData[i].value == "") {
			alert("No [" + propertyData[i].name + "] value in properties");
			return;
		}
		delim = ",";
	}
	jobParams += '}';

	if(!confirm("Are you sure saving [" + jobName + "]?")) {
		return;
	}
	
	$.ajax({
		url: APPLICATION_CONTEXT + 'workflow/saveJob.do', 
		type: 'POST',
		async: false,
		data: { 
			appName: appName,
			jobName: jobName,
			scheduleInfo: scheduleInfo,
			description: description,
			jobParams: jobParams,
			userName: userName,
			mailTo: mailTo,
			mailOnlyFail: mailOnlyFail
		},
		success: function(result) {
			if(!result.success) {
				alert(result.msg);
				return;
			} else {
				alert("Successfully saved");
				$('#jobDetailDialog').dialog('close');
				getJobList();
			}
		}
	});	
}

function getJobList() {
	$.ajax({
		url: APPLICATION_CONTEXT + 'workflow/listJob.do', 
		type: 'GET',
		async: false,
		success: function(result) {
			if(!result.success) {
				alert(result.msg);
				return;
			} else {
				$("#scheduleJobTable").jqGrid("clearGridData");
				for(var i = 0; i < result.data.length; i++) {
					var job = result.data[i];
					
					$("#scheduleJobTable").jqGrid('addRowData', job.jobName, job);
				}
			}
		}
	});	
}

function appSelected(appInfo) {
	$("#appXml").val(appInfo.xml);
}

function setScheduleTime(type, subtype) {
	var scheduleTimeField = $("#scheduleSettingTime");
	var oldTimeValue = scheduleTimeField.val().split(" ");

	var changed = false;
	if(type == 'minute') {
		if(subtype == 2) {
			var value = $('#schedule-time-every-n-minute').val();
			if(value != "") {
				$('#schedule-time-every-minute').attr('checked', false);
				$('#schedule-time-selected-minute').val("");
				oldTimeValue[0] = "*/" + value;
				changed = true;
			}
		}
		if(subtype == 3) {
			var value = $('#schedule-time-selected-minute').val();
			if(value != "") {
				$('#schedule-time-every-minute').attr('checked', false);
				$('#schedule-time-every-n-minute').val("");
				oldTimeValue[0] = value;
				changed = true;
			}
		}
		if(subtype == 1) {	
			var checked = $('#schedule-time-every-minute').is(':checked');
			if(checked) {
				$('#schedule-time-every-n-minute').val("");
				$('#schedule-time-selected-minute').val("");
				oldTimeValue[0] = "*";
				changed = true;
			}
		}
	} else if(type == 'hour') {
		if(subtype == 2) {
			var value = $('#schedule-time-every-n-hour').val();
			if(value != "") {
				$('#schedule-time-every-hour').attr('checked', false);
				$('#schedule-time-selected-hour').val("");
				oldTimeValue[1] = "*/" + value;
				changed = true;
			}
		}
		if(subtype == 3) {
			var value = $('#schedule-time-selected-hour').val();
			if(value != "") {
				$('#schedule-time-every-hour').attr('checked', false);
				$('#schedule-time-every-n-hour').val("");
				oldTimeValue[1] = value;
				changed = true;
			}
		}
		if(subtype == 1) {	
			var checked = $('#schedule-time-every-hour').is(':checked');
			if(checked) {
				$('#schedule-time-every-n-hour').val("");
				$('#schedule-time-selected-hour').val("");
				oldTimeValue[1] = "*";
				changed = true;
			}
		}
	} else if(type == 'dayofmonth') {
		if(subtype == 2) {
			var value = $('#schedule-time-selected-day').val();
			if(value != "") {
				$('#schedule-time-every-day').attr('checked', false);
				oldTimeValue[2] = value;
				changed = true;
			}
		}
		if(subtype == 1) {	
			var checked = $('#schedule-time-every-day').is(':checked');
			if(checked) {
				$('#schedule-time-selected-day').val("");
				oldTimeValue[2] = "*";
				changed = true;
			}
		}
	} else if(type == 'month') {
		if(subtype == 2) {
			var value = $('#schedule-time-selected-month').val();
			if(value != "") {
				$('#schedule-time-every-month').attr('checked', false);
				oldTimeValue[3] = value;
				changed = true;
			}
		}
		if(subtype == 1) {	
			var checked = $('#schedule-time-every-month').is(':checked');
			if(checked) {
				$('#schedule-time-selected-month').val("");
				oldTimeValue[3] = "*";
				changed = true;
			}
		}
	} else if(type == 'week') {
		if(subtype == 2) {
			var checkedValue = "";
			var delim = "";
			for(var i = 0; i < 7; i++) {
				var value = $('#schedule-time-selected-week' + i).is(':checked');
				if(value == true) {
					changed = true;
					checkedValue += delim + i;
					delim = ",";
				}
			}
			
			if(changed) {
				$('#schedule-time-every-week').attr('checked', false);
				oldTimeValue[4] = checkedValue;
			}
		}
		if(subtype == 1) {	
			var checked = $('#schedule-time-every-week').val();
			if(checked) {
				for(var i = 0; i < 7; i++) {
					$('#schedule-time-selected-week' + i).attr('checked', false);
				}
				oldTimeValue[4] = "*";
				changed = true;
			}
		}
	}
	
	if(changed) {
		var result = "";
		var delim = "";
		for(var i = 0; i < oldTimeValue.length; i++) {
			result += delim + oldTimeValue[i];
			delim = " ";
		}
		scheduleTimeField.val(result);
	}
}	
</script>

</head>
<body>
<!-- 
<div id="main" class="x-hide-display">
 -->
  <div id="layout-container" style="width: 100%; height:100%; padding:0;">
	<div id="westPane" style="margin:0px;padding:0px">
		<div class="workflow-subtitle">Workflow Apps.</div>
		<div style="padding:5px">
			<div>
				<div style='float:left'>
					<button id="refreshAppButton">refresh</button>
				</div>
				<div style='float:right'>
					<button id="newInstanceButton">new instance</button>
					<button id="runAppButton">run</button>
					<button id="editAppButton">edit</button>
					<button id="deleteAppButton">delete</button>
				</div>
				<div style='clear:both'></div>
			</div>
			<div>
				<table id="appListTable"></table>
			</div>		
		</div>
		<div class="workflow-subtitle">App. Definition</div>
		<div style="padding:5px">
			<button id="saveAppButton">save</button>
			<textarea id="appXml" style="width:390px; height:250px; font-size:11px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto;" wrap="off"></textarea>
		</div>
	</div>
	<div id="centerPane" style="margin:0px;padding:0px;">
		<div id="centerTopPane" style="padding:0px;border:0px">
			<div class="workflow-subtitle">Scheduled Jobs</div>
			<div style="padding:5px">
				<div>
					<div style="float:left">
						<button id="refreshJobButton">refresh</button>
					</div>
					<div style="float:right">
						<button id="runJobNowButton">run now</button>
						<button id="jobDetailButton">detail</button>
						<button id="jobDeleteButton">delete</button>
					</div>
					<div style="clear:both"></div>
				</div>
				<div>
					<table id="scheduleJobTable"></table>
				</div>
			</div>
		</div>
		<div id="centerCenterPane" style="padding:0px;border:0px">
			<div class="workflow-subtitle">Job Execution History</div>
			<div style="padding:5px">
				<div style="font-size:11px">
					<div style="float:left">
						job name: <input type="text" id="jobHistoryJobName" style="width:200px"/>&nbsp;&nbsp;
						date: <input type="text" id="jobHistoryFromTime"/> ~ <input type="text" id="jobHistoryToTime"/>
						<button id="jobHistoryButton">search</button>
						<button id="jobHistoryDetailButton">detail</button>
					</div>
					<div style="float:right">
						<button id="killJobButton">kill</button>
						<button id="suspendJobButton">suspend</button>
						<button id="resumeJobButton">resume</button>
					</div>
					<div style='clear:both'></div>
				</div>
				<div>
					<table id="jobHistoryTable">
					</table>
				</div>
			</div>
		</div>
	</div>
  </div>
<!--  
</div>
 -->
<div id="jobDetailDialog">
	<div>
		<div class="layout_input"><span style='display:inline-block; width:100px'>Job name:</span><input type='text' id='jobDetailJobName' style="width:550px"/></div>
		<div class="layout_input"><span style='display:inline-block; width:100px'>App name:</span><input type='text' id='jobDetailAppName' readonly="readonly" style="width:550px"/></div>
		<div class="layout_input"><span style='display:inline-block; width:100px'>User name:</span><input type='text' id='jobDetailUserName' style="width:550px"/></div>
		<div class="layout_input"><span style='display:inline-block; width:100px'>Mail to:</span><input type='text' id='jobDetailMailTo' style="width:550px"/></div>
		<div class="layout_input"><span style='display:inline-block; width:100px'>Mail only fail:</span><input type='checkbox' id='jobDetailMailOnlyFail'/></div>
		<div class="layout_input">
			<span style='display:inline-block; width:100px'>Scheduling</span><input type='text' id='scheduleTime' style="width:480px" value="* * * * *"/>
			<button id="scheduleSettingButton">setting...</button>
		</div>
		<div class="layout_input"><span style='display:inline-block; width:100px'>Description:</span><input type='text' id='jobDetailDescription' style="width:550px"/></div>
		<div class="layout_input">
			<div>
				<div id="jobPropertyTab">
					<ul>
						<li><a href="#tab_1"><span>Job Properties</span></a></li>
						<li><a href="#tab_2"><span>Applicaiton XML</span></a></li>
					</ul>
					<div id="tab_1">					
						<div style="text-align:right; margin-top:5px">
							<button id="addPropertyButton">add</button>
							<button id="modifyPropertyButton">modify</button>
							<button id="removePropertyButton">remove</button>
						</div>
						<table id="jobPropertiesTable"></table>
					</div>
					<div id="tab_2">					
						<textarea id="jobDetailXml" style="width:650px; height:300px; font-size:11px; margin: 5px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto;" wrap="off" readonly="readonly"></textarea>
					</div>				
				</div>
			</div>
		</div>
	</div>
</div>

<div id="scheduleSettingDialog">
	<div class="layout_input">
		Scheduling: <input type="text" id="scheduleSettingTime" style="width:500px" value="* * * * *"/>
	</div>
	<div id="scheduleDetail">
		<h3><a href="#">Minute</a></h3>
		<div>
			<div class="layout_input">Every minute: <input type="checkbox" id="schedule-time-every-minute"/> or</div>
			<div class="layout_input">Every N minute: <input type="text" id="schedule-time-every-n-minute" style="width:40px"/> (1 ~ 60) or</div>			
			<div class="layout_input">Every selected minute: <input type="text" id="schedule-time-selected-minute" style="width:200px"/> (0~ 59, comma seperator) </div>				
		</div>
		<h3><a href="#">Hour</a></h3>
		<div>
			<div class="layout_input">Every hour: <input type="checkbox" id="schedule-time-every-hour"/> or</div>
			<div class="layout_input">Every N hour: <input type="text" id="schedule-time-every-n-hour" style="width:40px"/> (1 ~ 24) or</div>				
			<div class="layout_input">Every selected hour: <input type="text" id="schedule-time-selected-hour" style="width:200px"/> (0~ 23, comma seperator) </div>				
		</div>
		<h3><a href="#">Day of month</a></h3>
		<div>
			<div class="layout_input">Every day: <input type="checkbox" id="schedule-time-every-day"/> or</div>
			<div class="layout_input">Every selected day: <input type="text" id="schedule-time-selected-day" style="width:200px"/> (01~ 31, comma seperator) </div>				
		</div>
		<h3><a href="#">Month</a></h3>
		<div>
			<div class="layout_input">Every month: <input type="checkbox" id="schedule-time-every-month"/> or</div>
			<div class="layout_input">Every selected month: <input type="text" id="schedule-time-selected-month" style="width:200px"/> (1~ 12, comma seperator) </div>				
		</div>
		<h3><a href="#">Day of week</a></h3>
		<div>
			<div class="layout_input">Every day of the week: <input type="checkbox" id="schedule-time-every-week"/> or</div>
			<div class="layout_input">Every selected day of week: </div>
			<div style="margin-left: 50px">
				<span style="display:inlock-block; width:70px">Sun: <input type="checkbox" id="schedule-time-selected-week0"/></span>
				<span style="display:inlock-block; width:70px">Mon: <input type="checkbox" id="schedule-time-selected-week1"/></span>
				<span style="display:inlock-block; width:70px">Tue: <input type="checkbox" id="schedule-time-selected-week2"/></span>
				<span style="display:inlock-block; width:70px">Wed: <input type="checkbox" id="schedule-time-selected-week3"/></span>
				<span style="display:inlock-block; width:70px">Thu: <input type="checkbox" id="schedule-time-selected-week4"/></span>
				<span style="display:inlock-block; width:70px">Fri: <input type="checkbox" id="schedule-time-selected-week5"/></span>
				<span style="display:inlock-block; width:70px">Sat: <input type="checkbox" id="schedule-time-selected-week6"/></span>
			</div>				
		</div>
	</div>
</div>
<%@ include file="./common_dialog.jsp"%>
</body>
</html>