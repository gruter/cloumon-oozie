<div id="runAppDetailDialog">
	<div>
		<div class="layout_input"><span style='display:inline-block; width:100px'>App name:</span><input type='text' id='runAppDetailAppName' readonly="readonly" style="width:550px"/></div>
		<div class="layout_input" style="margin-top:5px"><span style='display:inline-block; width:100px'>User name:</span><input type='text' id='runAppDetailUserName' style="width:550px"/></div>
		<div class="layout_input" style="margin-top:5px"><span style='display:inline-block; width:100px'>Mail to:</span><input type='text' id='runAppDetailMailTo' style="width:550px"/></div>
		<div class="layout_input" style="margin-top:5px">
			<div>
				<button id="modifyRunAppPropertyButton">modify</button>
			</div>
			<table id="runAppPropertiesTable"></table>
		</div>
	</div>	
</div>

<div id="jobStatusDetailDialog">
	<div style="margin-top:5px;margin-right:5px;">
		<div style='float:left;font-weight:bold'>&nbsp;&nbsp;Job Overview</div>
		<div style='float:right;'><button id="jobStatusRefreshButton">refresh</button></div>
	</div>
	<table>
	<tr>
		<td width="500px" valign="top">
			<div class="ui-widget ui-widget-content ui-corner-all">
				<div style="margin-top:5px"><span class="label_title">Job Id:</span><input type="text" readonly="readonly" id="jobstatus_jobId" class="label_value"></input></div>
				<div style="margin-top:5px"><span class="label_title">Name:</span><input type="text" readonly="readonly" id="jobstatus_jobName" class="label_value"></input></div>
				<div style="margin-top:5px"><span class="label_title">App Path:</span><input type="text" readonly="readonly" id="jobstatus_appPath" class="label_value"></input></div>
				<div style="margin-top:5px"><span class="label_title">Run:</span><input type="text" readonly="readonly" id="jobstatus_run" class="label_value"></input></div>
				<div style="margin-top:5px"><span class="label_title">Status:</span><input type="text" readonly="readonly" id="jobstatus_status" class="label_value"></input></div>
				<div style="margin-top:5px"><span class="label_title">User:</span><input type="text" readonly="readonly" id="jobstatus_user" class="label_value"></input></div>
				<div style="margin-top:5px"><span class="label_title">Group:</span><input type="text" readonly="readonly" id="jobstatus_group" class="label_value"></input></div>
				<div style="margin-top:5px"><span class="label_title">Create Time:</span><input type="text" readonly="readonly" id="jobstatus_createTime" class="label_value"></input></div>
				<div style="margin-top:5px"><span class="label_title">Start Time:</span><input type="text" readonly="readonly" id="jobstatus_startTime" class="label_value"></input></div>
				<div style="margin-top:5px"><span class="label_title">End Time:</span><input type="text" readonly="readonly" id="jobstatus_endTime" class="label_value"></input></div>
			</div>
			<div style="margin-top:10px; height:300px">
				<div style='margin-top:5px;font-weight:bold'>&nbsp;&nbsp;Actions</div>
				<table id="actionListTable"></table>
			</div>
		</td>
		<td width="500px" valign="top">
			<div>
				<div id="job_status_tab_container">
					<ul>
						<li><a href="#job_status_tab_1"><span>Job Xml</span></a></li>
						<li><a href="#job_status_tab_2"><span>Job Properties</span></a></li>
						<li><a href="#job_status_tab_3"><span>Job Log</span></a></li>
						<li><a href="#job_status_tab_4"><span id="actionDetailTabTitle">Action Detail</span></a></li>
						<li><a href="#job_status_tab_5"><span id="actionXmlTabTitle">Action Xml</span></a></li>
					</ul>
					<div id="job_status_tab_1">
						<div style="height:550px; width:450px">
							<textarea id="job_status_app_xml" style="width:440px; height:520px; font-size:11px; margin: 5px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto;" wrap="off"></textarea>
						</div>
					</div>
					<div id="job_status_tab_2">
						<div style="height:550px; width:450px">
							<table id="job_status_job_property_table"></table>
						</div>
					</div>
					<div id="job_status_tab_3">
						<div style="height:550px; width:450px">
							<div style="text-align:right;margin-top:5px"><button id="jobLogRefreshButton">refresh</button></div>
							<textarea id="job_status_log" style="width:440px; height:515px; font-size:11px; margin: 5px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto;" wrap="off"></textarea>
						</div>
					</div>
					<div id="job_status_tab_4">
						<div style="height:550px; width:450px">
							<div style="margin-top:5px"><span class="label_title2">Action Id:</span><input type="text" readonly="readonly" id="jobstatus_action_id" class="label_value2"></input></div>
							<div style="margin-top:5px"><span class="label_title2">Name:</span><input type="text" readonly="readonly" id="jobstatus_action_name" class="label_value2"></input></div>
							<div style="margin-top:5px"><span class="label_title2">Type:</span><input type="text" readonly="readonly" id="jobstatus_action_type" class="label_value2"></input></div>
							<div style="margin-top:5px"><span class="label_title2">Transition:</span><input type="text" readonly="readonly" id="jobstatus_action_transition" class="label_value2"></input></div>
							<div style="margin-top:5px"><span class="label_title2">Start Time:</span><input type="text" readonly="readonly" id="jobstatus_action_startTime" class="label_value2"></input></div>
							<div style="margin-top:5px"><span class="label_title2">End Time:</span><input type="text" readonly="readonly" id="jobstatus_action_endTime" class="label_value2"></input></div>
							<div style="margin-top:5px"><span class="label_title2">Status:</span><input type="text" readonly="readonly" id="jobstatus_action_status" class="label_value2"></input></div>
							<div style="margin-top:5px"><span class="label_title2">Error Code:</span><input type="text" readonly="readonly" id="jobstatus_action_errorCode" class="label_value2"></input></div>
							<div style="margin-top:5px"><span class="label_title2">Error Message:</span><input type="text" readonly="readonly" id="jobstatus_action_errorMessage" class="label_value2"></input></div>
							<div style="margin-top:5px"><span class="label_title2">External ID:</span><input type="text" readonly="readonly" id="jobstatus_action_externalId" class="label_value2"></input></div>
							<div style="margin-top:5px"><span class="label_title2">External Status:</span><input type="text" readonly="readonly" id="jobstatus_action_externalStatus" class="label_value2"></input></div>
							<div style="margin-top:5px"><span class="label_title2">Console URL:</span><input type="text" readonly="readonly" id="jobstatus_action_consoleUrl" class="label_value3"></input>
								<div style='float:right'><span class='ui-icon ui-icon-search' style='cursor:pointor' id='jobstatus_action_consoleButton'></span></div>
								<div style='clear:both'></div>
							</div>
							<div style="margin-top:5px"><span class="label_title2">Tracker URI:</span><input type="text" readonly="readonly" id="jobstatus_action_trackerUri" class="label_value2"></input></div>
						</div>							
					</div>
					<div id="job_status_tab_5">
						<div style="height:550px; width:300px">
							<textarea id="job_status_action_xml" style="width:440px; height:520px; font-size:11px; margin: 5px; border: solid 1px #AAAAAA; border-radius:4px; overflow: auto;" wrap="off"></textarea>
						</div>
					</div>
				</div>
			</div>
		</td>
	</tr>
	</table>
</div>

<script type="text/javascript">
$("#modifyRunAppPropertyButton").click(function() {
	var name = $("#runAppPropertiesTable").jqGrid('getGridParam', 'selrow');

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
	
	$("#runAppPropertiesTable").jqGrid('editGridRow', name, editSettings);
	$("#FrmGrid_runAppPropertiesTable input[name=name]").attr("readonly", true);
});

$("#jobStatusRefreshButton").click(function() {
	workflowUtil.showJobDetailView($("#jobstatus_jobId").val());
});

$("#runAppPropertiesTable").jqGrid({
	datatype: "local",
	height: 200,
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
		$("#modifyRunAppPropertyButton").click();
	}
});

$('#runAppDetailDialog').dialog({ 
	width: 700, height: 500, modal: true, autoOpen: false,
	title: 'Run Application',
	buttons: [{
		text: "Run",
		click: function() {
			var appName = $("#runAppDetailAppName").val();
			var userName = $("#runAppDetailUserName").val();
			if(userName == null) {
				alert("No user name");
				return;
			}
			var mailTo = $("#runAppDetailMailTo").val();
			
			var propertyData = $("#runAppPropertiesTable")[0].p.data;
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
				
			$.ajax({
				url: APPLICATION_CONTEXT + 'workflow/runApp.do', 
				type: 'POST',
				async: false,
				data: { 
					appName: appName,
					userName: userName,
					mailTo: mailTo,
					jobParams: jobParams
				},
				success: function(result) {
					if(!result.success) {
						alert(result.msg);
						return;
					} else {
						alert(result.data + " executed");
						$('#runAppDetailDialog').dialog('close');
					}
				}
			});			
		}
	}, {
    	text: "Close",
        click: function() {
        	$(this).dialog("close");
        }
	}]
});

$('#jobStatusDetailDialog').dialog({
	width: 1000, height: 720, modal: true, autoOpen: false,
	title: 'Job',
	buttons: [{ 
		text: "Ok",
		click: function() {
	    	$(this).dialog("close");
		}
	}]
});

$("#actionListTable").jqGrid({
	datatype: "local",
	height: 270,
	width: 500,
	rowNum: 100000,
   	colNames:['Action Id', 'Name', 'Type', 'Status', 'Transition', 'Start Time', 'End Time', 'errorCode', 'errorMessage', 'externalId', 'externalStatus', 'consoleUrl', 'trackerUri','conf'],
   	colModel:[
   		{name:'id',index:'id', width:200, sortable:false, hidden: true},
   		{name:'name',index:'name', width:70, sortable:false},
   		{name:'type',index:'type', width:70, sortable:false},
   		{name:'status',index:'status', width:70, sortable:false},
   		{name:'transition',index:'transition', width:70, sortable:false, hidden: true},
   		{name:'startTime',index:'startTime', width:120, sortable:false, formatter: dateFormatter},
   		{name:'endTime',index:'endTime', width:120, sortable:false, formatter: dateFormatter},
   		{name:'errorCode',index:'errorCode', width:70, sortable:false, hidden: true},
   		{name:'errorMessage',index:'errorMessage', width:70, sortable:false, hidden: true},
   		{name:'externalId',index:'externalId', width:70, sortable:false, hidden: true},
   		{name:'externalStatus',index:'externalStatus', width:70, sortable:false, hidden: true},
   		{name:'consoleUrl',index:'consoleUrl', width:70, sortable:false, hidden: true},
   		{name:'trackerUri',index:'trackerUri', width:70, sortable:false, hidden: true},
   		{name:'conf',index:'conf', width:70, sortable:false, hidden: true}
   	],
   	onSelectRow: function(id) {
		var name = $("#actionListTable").jqGrid('getCell', id, 'name');
		
		$("#jobstatus_action_id").val($("#actionListTable").jqGrid('getCell', id, 'id'));
		$("#jobstatus_action_name").val($("#actionListTable").jqGrid('getCell', id, 'name'));
		$("#jobstatus_action_type").val($("#actionListTable").jqGrid('getCell', id, 'type'));
		$("#jobstatus_action_transition").val($("#actionListTable").jqGrid('getCell', id, 'transition'));
		$("#jobstatus_action_startTime").val($("#actionListTable").jqGrid('getCell', id, 'startTime'));
		$("#jobstatus_action_endTime").val($("#actionListTable").jqGrid('getCell', id, 'endTime'));
		$("#jobstatus_action_status").val($("#actionListTable").jqGrid('getCell', id, 'status'));
		$("#jobstatus_action_errorCode").val($("#actionListTable").jqGrid('getCell', id, 'errorCode'));
		$("#jobstatus_action_errorMessage").val($("#actionListTable").jqGrid('getCell', id, 'errorMessage'));
		$("#jobstatus_action_externalId").val($("#actionListTable").jqGrid('getCell', id, 'externalId'));
		$("#jobstatus_action_externalStatus").val($("#actionListTable").jqGrid('getCell', id, 'externalStatus'));
		$("#jobstatus_action_consoleUrl").val($("#actionListTable").jqGrid('getCell', id, 'consoleUrl'));
		$("#jobstatus_action_trackerUri").val($("#actionListTable").jqGrid('getCell', id, 'trackerUri'));

		$("#job_status_action_xml").val($("#actionListTable").jqGrid('getCell', id, 'conf'));
		$("#jobstatus_action_consoleButton").unbind('click');
		$("#jobstatus_action_consoleButton").click(function(event) {
			var url = $("#jobstatus_action_consoleUrl").val();
			if(url != null && url != "") {
				event.preventDefault();
				event.stopPropagation();
				window.open(url, '_blank');
			}
		});
		
		$("#job_status_tab_container").tabs("select", "job_status_tab_4");
	}
});


</script>
