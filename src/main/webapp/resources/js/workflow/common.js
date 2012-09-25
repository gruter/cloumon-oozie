var workflowUtil = {
	initAppListTable: function(tableId, width, height, selectCallback) {
		//init app list table
		$("#" + tableId).jqGrid({
			datatype: "local",
			height: height,
			width: width,
		   	colNames:['App Name', 'Creator', 'Description', 'xml'],
		   	colModel:[
		   		{name:'appName',index:'appName', width:100, sortable:true},
		   		{name:'creator',index:'creator', width:50, sortable:false},
		   		{name:'description',index:'description', width:(width - 150), sortable:false},
		   		{name: 'xml', index:'xml', hidden: true , editable: false, formatter: function(val) { if(val == null) return "";	return val.replace(/<script>/g,"[script]").replace(/<\/script>/g, "[/script]"); } }
		   	],
			onSelectRow: function(appName) {
				if(selectCallback != undefined) {
					var appName = $("#" + tableId).jqGrid('getGridParam', 'selrow');
					var gridData = $("#" + tableId)[0].p.data;
					for(var i = 0; i < gridData.length; i++) {
						if(gridData[i].appName == appName) {
							selectCallback(gridData[i]);
						}
					}
				}
			}
		});
	},
	loadAppListTable : function(tableId) {
		$.ajax({
			url: APPLICATION_CONTEXT + 'workflow/listApp.do', 
			type: 'GET',
			async: false,
			success: function(result) {
				if(!result.success) {
					alert(result.msg);
					return;
				} else {
					$("#" + tableId).jqGrid("clearGridData");
					for(var i = 0; i < result.data.length; i++) {
						$("#" + tableId).jqGrid('addRowData', result.data[i].appName, result.data[i]);
					}
				}
			}
		});		
	},
	getTableSelectedData: function(tableId) {
		var rowId = $("#" + tableId).jqGrid('getGridParam', 'selrow');
		if(rowId == null || rowId == undefined) {
			return null;
		}
		var gridData = $("#" + tableId)[0].p.data;
		for(var i = 0; i < gridData.length; i++) {
			if(gridData[i].id == rowId) {
				return gridData[i];
			}
		}
		
		return null;
	},
	getTableData: function(tableId, rowId) {
		var gridData = $("#" + tableId)[0].p.data;
		for(var i = 0; i < gridData.length; i++) {
			if(gridData[i].id == rowId) {
				return gridData[i];
			}
		}
		
		return null;
	},
	deleteApp: function(tableId, callback) {
		var appName = $("#" + tableId).jqGrid("getGridParam", "selrow");
		if(appName == null || appName == "") {
			alert("select applicaiton.");
			return;
		}

		if(!confirm("Deleting [" + appName + "]")) {
			return;
		}
		$.ajax({
			url: APPLICATION_CONTEXT + 'workflow/deleteApp.do', 
			type: 'GET',
			async: false,
			data: {
				appName: appName
			},
			success: function(data) {
				if(!data.success) {
					alert(data.msg);
					return
				} else {
					if(callback != null) {
						callback(appName);
					}
				}
			}
		});		
	},
	/*
	 * get hive or pig query in file(hdfs)
	 */
	getQueryInFile: function(fileName, appName) {
		if(this.endsWith(fileName, ".jar")) {
			return "";
		}
		if(appName == null || appName == "") {
			return null;
		}
		var query = null;
		
		$.ajax({
			url: APPLICATION_CONTEXT + 'workflow/getQuery.do', 
			type: 'GET',
			async: false,
			data: { appName: appName, queryFile: fileName },
			success: function(result) {
				if(!result.success) {
					alert(result.msg);
					return;
				} else {
					query = result.data;			
				}
			}
		});		

		return query;
	},
	endsWith: function (str, suffix) {
	    return str.indexOf(suffix, str.length - suffix.length) !== -1;
	}, 
	showRunAppDialog: function(appInfo) {
		var appName = appInfo.appName;
		$.ajax({
			url: APPLICATION_CONTEXT + 'workflow/findProperty.do', 
			type: 'POST',
			async: false,
			data: { xml: appInfo.xml },
			success: function(result) {
				if(!result.success) {
					alert(result.msg);
					return;
				} else {
					$("#runAppDetailAppName").val(appName);
					$("#runAppDetailUserName").val('');
					$("#runAppDetailMailTo").val('');
					$("#runAppPropertiesTable").jqGrid("clearGridData");

					$("#runAppPropertiesTable").jqGrid('addRowData', "oozie.use.system.libpath", { name: "oozie.use.system.libpath", value: "true"});
					for(var i = 0; i < result.data.length; i++) {
						var recordData = { name: result.data[i], value: ""};
						$("#runAppPropertiesTable").jqGrid('addRowData', result.data[i], recordData);
					}
					$('#runAppDetailDialog').dialog('open');
				}
			}
		});	
	},
	showJobLog: function() {
		$.ajax({
			url: APPLICATION_CONTEXT + 'workflow/getJobLog.do', 
			type: 'GET',
			async: false,
			data: { jobId: $("#jobstatus_jobId").val() },
			success: function(result) {
				if(!result.success) {
					alert(result.msg);
					return;
				} else {
					$("#job_status_log").val(result.data);
				}
			}
		});	
	},	
	showJobDetailView: function(jobId) {
		if($("#jobStatusDetailDialog").dialog('isOpen') != true) {
			$('#jobStatusDetailDialog').dialog('option', 'title', 'Job detail [' + jobId + ']');
			$("#jobStatusDetailDialog").dialog('open');
		} 
		$.ajax({
			url: APPLICATION_CONTEXT + 'workflow/getJobStatus.do', 
			type: 'GET',
			async: false,
			data: { jobId: jobId },
			success: function(result) {
				if(!result.success) {
					alert(result.msg);
					return;
				} else {
					$("#jobstatus_action_id").val('');
					$("#jobstatus_action_name").val('');
					$("#jobstatus_action_type").val('');
					$("#jobstatus_action_transition").val('');
					$("#jobstatus_action_startTime").val('');
					$("#jobstatus_action_endTime").val('');
					$("#jobstatus_action_status").val('');
					$("#jobstatus_action_errorCode").val('');
					$("#jobstatus_action_errorMessage").val('');
					$("#jobstatus_action_externalId").val('');
					$("#jobstatus_action_externalStatus").val('');
					$("#jobstatus_action_consoleUrl").val('');
					$("#jobstatus_action_trackerUri").val('');
					$("#job_status_action_xml").val('');
					
					var jobStatus = result.data;

					$("#jobstatus_jobId").val(jobStatus.id);
					$("#jobstatus_jobName").val(jobStatus.jobName);
					$("#jobstatus_appPath").val(jobStatus.appPath);
					$("#jobstatus_run").val(jobStatus.run);
					$("#jobstatus_status").val(jobStatus.status);
					$("#jobstatus_user").val(jobStatus.user);
					$("#jobstatus_group").val(jobStatus.group);
					$("#jobstatus_createTime").val(dateFormatter(jobStatus.createTime));
					$("#jobstatus_startTime").val(dateFormatter(jobStatus.startTime));
					$("#jobstatus_endTime").val(dateFormatter(jobStatus.endTime));

					$("#job_status_app_xml").val(jobStatus.conf);
					
					var actions = jobStatus.actions;
					$("#actionListTable").jqGrid("clearGridData");
					for(var i = 0; i < actions.length; i++) {
						$("#actionListTable").jqGrid('addRowData', actions[i].id, actions[i]);
					}
					$("#job_status_app_xml").val(jobStatus.xml);

					$("#job_status_job_property_table").jqGrid("clearGridData");
					for (var key in jobStatus.configMap) {
						var propertyRecord = { key: key, value: jobStatus.configMap[key] };
						$("#job_status_job_property_table").jqGrid('addRowData', key, propertyRecord);
					}

					$('#job_status_tab_container').tabs('select', 0);
				}
			}
		});	
	},
	getCommonLibFiles: function(type) {
		var returnValue = null;
		$.ajax({
			url: APPLICATION_CONTEXT + 'workflow/getCommonFiles.do', 
			type: 'GET',
			async: false,
			data: {
				type: type
			},
			success: function(result) {
				if(!result.success) {
					alert(result.msg);
				} else {
					returnValue = result.data;
				}
			}
		});	
		
		return returnValue;
	}
};

var dateFormat = function () {
	var	token = /d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g,
		timezone = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g,
		timezoneClip = /[^-+\dA-Z]/g,
		pad = function (val, len) {
			val = String(val);
			len = len || 2;
			while (val.length < len) val = "0" + val;
			return val;
		};

	// Regexes and supporting functions are cached through closure
	return function (date, mask, utc) {
		var dF = dateFormat;

		// You can't provide utc if you skip other args (use the "UTC:" mask prefix)
		if (arguments.length == 1 && Object.prototype.toString.call(date) == "[object String]" && !/\d/.test(date)) {
			mask = date;
			date = undefined;
		}

		// Passing date through Date applies Date.parse, if necessary
		date = date ? new Date(date) : new Date;
		if (isNaN(date)) throw SyntaxError("invalid date");

		mask = String(dF.masks[mask] || mask || dF.masks["default"]);

		// Allow setting the utc argument via the mask
		if (mask.slice(0, 4) == "UTC:") {
			mask = mask.slice(4);
			utc = true;
		}

		var	_ = utc ? "getUTC" : "get",
			d = date[_ + "Date"](),
			D = date[_ + "Day"](),
			m = date[_ + "Month"](),
			y = date[_ + "FullYear"](),
			H = date[_ + "Hours"](),
			M = date[_ + "Minutes"](),
			s = date[_ + "Seconds"](),
			L = date[_ + "Milliseconds"](),
			o = utc ? 0 : date.getTimezoneOffset(),
			flags = {
				d:    d,
				dd:   pad(d),
				ddd:  dF.i18n.dayNames[D],
				dddd: dF.i18n.dayNames[D + 7],
				m:    m + 1,
				mm:   pad(m + 1),
				mmm:  dF.i18n.monthNames[m],
				mmmm: dF.i18n.monthNames[m + 12],
				yy:   String(y).slice(2),
				yyyy: y,
				h:    H % 12 || 12,
				hh:   pad(H % 12 || 12),
				H:    H,
				HH:   pad(H),
				M:    M,
				MM:   pad(M),
				s:    s,
				ss:   pad(s),
				l:    pad(L, 3),
				L:    pad(L > 99 ? Math.round(L / 10) : L),
				t:    H < 12 ? "a"  : "p",
				tt:   H < 12 ? "am" : "pm",
				T:    H < 12 ? "A"  : "P",
				TT:   H < 12 ? "AM" : "PM",
				Z:    utc ? "UTC" : (String(date).match(timezone) || [""]).pop().replace(timezoneClip, ""),
				o:    (o > 0 ? "-" : "+") + pad(Math.floor(Math.abs(o) / 60) * 100 + Math.abs(o) % 60, 4),
				S:    ["th", "st", "nd", "rd"][d % 10 > 3 ? 0 : (d % 100 - d % 10 != 10) * d % 10]
			};

		return mask.replace(token, function ($0) {
			return $0 in flags ? flags[$0] : $0.slice(1, $0.length - 1);
		});
	};
}();

// Some common format strings
dateFormat.masks = {
	"default":      "ddd mmm dd yyyy HH:MM:ss",
	shortDate:      "m/d/yy",
	mediumDate:     "mmm d, yyyy",
	longDate:       "mmmm d, yyyy",
	fullDate:       "dddd, mmmm d, yyyy",
	shortTime:      "h:MM TT",
	mediumTime:     "h:MM:ss TT",
	longTime:       "h:MM:ss TT Z",
	isoDate:        "yyyy-mm-dd",
	isoTime:        "HH:MM:ss",
	isoDateTime:    "yyyy-mm-dd'T'HH:MM:ss",
	isoUtcDateTime: "UTC:yyyy-mm-dd'T'HH:MM:ss'Z'"
};

// Internationalization strings
dateFormat.i18n = {
	dayNames: [
		"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat",
		"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
	],
	monthNames: [
		"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
		"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
	]
};

// For convenience...
Date.prototype.format = function (mask, utc) {
	return dateFormat(this, mask, utc);
};

function dateFormatter(cellvalue, options, rowObject) {
	if(cellvalue == 0 || cellvalue == null) {
		return "-";
	} else {
		return (new Date(cellvalue)).format("yyyy-mm-dd HH:MM:ss");
	}
}

