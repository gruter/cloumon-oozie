var designManager = {};

var defaultMrJobProperty = [ { name: 'mapred.mapper.class', value: ''}, 
                         	 { name: 'mapred.reducer.class', value: ''},
                         	 { name: 'mapred.combiner.class', value: ''},
                         	 { name: 'mapred.input.dir', value: '${inputDir}'},
                         	 { name: 'mapred.output.dir', value: '${outputDir}'},
                         	 { name: 'mapred.output.key.class', value: 'org.apache.hadoop.io.Text'},
                         	 { name: 'mapred.output.value.class', value: 'org.apache.hadoop.io.IntWritable'},
                         	 { name: 'mapred.input.format.class', value: 'org.apache.hadoop.mapred.TextInputForamt'},
                         	 { name: 'mapred.output.format.class', value: 'org.apache.hadoop.mapred.TextOutputForamt'},
                         	 { name: 'mapred.child.java.opts', value: '-Xmx256m'},
                         	 { name: 'mapred.map.tasks', value: '1'},
                         	 { name: 'mapred.reduce.tasks', value: '1'},
                         	 { name: 'mapred.job.queue.name', value: '${queueName}'}
                           ];
var endpoint = {
	endpoint:["Dot", { radius:8 }],
	paintStyle:{ width:8, height:8, fillStyle:"gray" },
	isSource:true,
	isTarget:true,
	detachable:true,
	connectorStyle : { lineWidth:3, strokeStyle: "#b8b8b8"},
	beforeDrop:function(params) { 
		var error = false;
		if(params.connection.endpoints.length > 0 && params.connection.endpoints[0].tooltip == 'error') {
			error = true;
		}

		designManager.itemConnected(params.sourceId, params.targetId, error);

		var sourceItem = designManager.allItems.get(params.connection.sourceId);
		if(sourceItem.itemType == 'decision') {
			var targetItem = designManager.allItems.get(params.connection.targetId);
			sourceItem.showConditionDialog(targetItem);
			params.connection.bind("click", function(conn) {
				sourceItem.showConditionDialog(targetItem);
			});
		}

		return true; 
	},			
	beforeDetach:function(conn) { 
		var error = false;
		if(conn.endpoints.length > 0 && conn.endpoints[0].tooltip == 'error') {
			error = true;
		}
		designManager.itemDisconnected(conn.sourceId, conn.targetId, error);
		return true;
	}
};

var multiConnEndpoint = {
		endpoint:["Dot", { radius:8 }],
		paintStyle:{ width:8, height:8, fillStyle:"gray" },
		isSource:true,
		isTarget:true,
		detachable:true,
		connectorStyle : { lineWidth:3, strokeStyle: "#b8b8b8" },
		beforeDrop:function(params) {
			//var sourceItem = designManager.allItems.get(params.connection.sourceId);
			var error = false;
			if(params.connection.endpoints.length > 0 && params.connection.endpoints[0].tooltip == 'error') {
				error = true;
			}
			designManager.itemConnected(params.sourceId, params.targetId, error);
			
			return true; 
		},			
		beforeDetach:function(conn) { 
			var error = false;
			if(conn.endpoints.length > 0 && conn.endpoints[0].tooltip == 'error') {
				error = true;
			}
			designManager.itemDisconnected(conn.sourceId, conn.targetId, error);
			return true;
		},
		maxConnections:10
};

var errorEndpoint = {
		endpoint:["Dot", { radius:8 }],
		paintStyle:{ width:8, height:8, fillStyle:"#eb6d5f" },
		isSource:true,
		isTarget:false,
		detachable:true,
		//scope: 'error',
		tooltip: 'error',
		connectorStyle : { lineWidth:3, strokeStyle: "#b8b8b8" },
		beforeDrop:function(params) {
			designManager.itemConnected(params.sourceId, params.targetId, true);
			return true; 
		},			
		beforeDetach:function(conn) { 
			designManager.itemDisconnected(conn.sourceId, conn.targetId, true);
			return true;
		}
};

designManager = {
	allItems: new HashMap(),
	createNewItem: function(itemType, updateMode) {
		var item = null;
		if(itemType == "map-reduce") {
			item = new MapReduceItem();
		} else if(itemType == "hive") {
			item = new HiveItem();
			if(updateMode == null || !updateMode) {
				item.setLibrary();
			}
		} else if(itemType == "pig") {
			item = new PigItem();
		} else if(itemType == "java") {
			item = new JavaItem();
		} else if(itemType == "ssh") {
			item = new SshItem();
		} else if(itemType == "fs") {
			item = new FsItem();
		} else if(itemType == "shell") {
			item = new ShellItem();
		} else if(itemType == "user-defined") {
			item = new UserDefinedItem();
		} else if(itemType == "start") {
			item = new StartItem();
		} else if(itemType == "end") {
			item = new EndItem(itemType);
		} else if(itemType == "kill") {
			item = new KillItem(itemType);
		} else if(itemType == "fork") {
			item = new ForkItem(itemType);
		} else if(itemType == "join") {
			item = new JoinItem(itemType);
		} else if(itemType == "decision") {
			item = new DecisionItem(itemType);
		} else {
			alert("Not support item type:" + itemType);
		}
		this.allItems.put(item.id, item);
		return item;
	},
	createItemsWithServerData: function(itemInfos) {
		var itemInfoMap = new HashMap();
		for(var i = 0; i < itemInfos.length; i++) {
			var item = this.createNewItem(itemInfos[i].itemType, true);
			item.name = itemInfos[i].name;
			
			itemInfoMap.put(item.id, itemInfos[i]);
		}
		
		var itemKeys = this.allItems.keys();
		for(var i = 0; i < itemKeys.length; i++) {
			var item = this.allItems.get(itemKeys[i]);
			var itemInfo = itemInfoMap.get(item.id);
			item.updateMode = true;
			item.initItemInfo(itemInfo);
		}
	},
	removeItem: function(itemId) {
		this.allItems.remove(itemId);
	},
	getItem: function(itemId) {
		return this.allItems.get(itemId);
	},
	clearAllItems: function() {
		var items = this.allItems.values();
		for(var i = 0; i < items.length; i++) {
			jsPlumb.detachAllConnections(items[i].id);
			jsPlumb.removeAllEndpoints(items[i].id);
			$("#" + items[i].id).remove();
		}
		this.allItems.clear();
	},
	findItemByName: function(name) {
		var items = this.allItems.values();
		for(var i = 0; i < items.length; i++) {
			if(items[i].name == name) {
				return items[i];
			}
		}
		return null;
	},
	connectAllItems: function() {
		var self = this;
		var items = this.allItems.values();
		for(var i = 0; i < items.length; i++) {
			items[i].initNextItemId();
		}
		var noNext = "";
		for(var i = 0; i < items.length; i++) {
			var sourceItem = items[i];
			if(sourceItem.itemType == 'decision') {
				var caseKeys = sourceItem.caseMap.keys();
				for(var j = 0; j < caseKeys.length; j++) {
					var targetItem = this.allItems.get(sourceItem.caseMap.get(caseKeys[j]).toId);
					var connection = jsPlumb.connect({uuids:[sourceItem.id + "BottomCenter", targetItem.id + "TopCenter"]});
					connection.bind("click", function(conn) {
						var decisionItem = self.getItem(conn.sourceId);
						decisionItem.showConditionDialogById(conn.targetId);
					});
				}
			} else if(sourceItem.itemType == 'fork') {
				var pathKeys = sourceItem.pathMap.keys();
				for(var j = 0; j < pathKeys.length; j++) {
					var targetItem = this.allItems.get(pathKeys[j]);
					var connection = jsPlumb.connect({uuids:[sourceItem.id + "BottomCenter", targetItem.id + "TopCenter"]});
				}				
			} else {
				if(sourceItem.okTo == null || sourceItem.okTo == '') {
					if(sourceItem.itemType != 'end' && sourceItem.itemType != 'kill') {
						noNext += sourceItem.name + ",";
					}
				} else {
					var targetItem = this.allItems.get(sourceItem.okTo);
					if(targetItem == null) {
						noNext += sourceItem.name + ",";
					} else {
						jsPlumb.connect({uuids:[sourceItem.id + "BottomCenter", targetItem.id + "TopCenter"]}); 
					}
				}
			}
			//error to
			if(sourceItem.errorTo != null && sourceItem.errorTo != '') {
				var targetItem = this.allItems.get(sourceItem.errorTo);
				if(targetItem != null) {
					jsPlumb.connect({uuids:[sourceItem.id + "RightMiddle", targetItem.id + "TopCenter"]}); 
				}
			}
		}
		if(noNext != "") {
			//alert("Can't find items:" + noNext);
		}
	},
	itemConnected: function(sourceId, targetId, errorConn) {
		var sourceItem = this.allItems.get(sourceId);
		var targetItem = this.allItems.get(targetId);

		if(errorConn) {
			sourceItem.errorTo = targetId;
		} else {
			sourceItem.okTo = targetId;
		}
		sourceItem.itemConnected(targetItem, errorConn);
	},
	itemDisconnected: function(sourceId, targetId, errorConn) {
		var sourceItem = this.allItems.get(sourceId);
		var targetItem = this.allItems.get(targetId);
		
		//console.log("disconnected:" + sourceItem.name + "," + targetItem.name);

		if(errorConn) {
			sourceItem.errorTo = null;
		} else {
			sourceItem.okTo = null;
		}
		sourceItem.itemDisconnected(targetItem, errorConn);
	},
	disconnectItem: function(sourceId, targetId, errorConn) {
		//this function for avoid recursive call
		var sourceItem = this.allItems.get(sourceId);
		var targetItem = this.allItems.get(targetId);
		
		//console.log("disconnect:" + sourceItem.name + "," + targetItem.name);
		var conns = jsPlumb.select({source: sourceId, target: targetId});
		if(conns != null && conns.length > 0) {
			conns.detach();
		}
	},
	verifyItems: function(appName) {
		var items = this.allItems.values();
		var namedMap = new HashMap();
		var startCount = 0;
		var endCount = 0;
		for(var i = 0; i < items.length; i++) {
			namedMap.put(items[i].name, i);
			if(items[i].itemType == 'start') {
				startCount++;
			} else if(items[i].itemType == 'end') {
				endCount++;
			}
		}
		if(startCount != 1) {
			alert('# start item must be one(' + startCount + ')');
			return false;
		}
		
		if(endCount != 1) {
			alert('# end item must be one(' + endCount + ')');
			return false;
		}
		
		for(var i = 0; i < items.length; i++) {
			if(namedMap.get(items[i].name) != i) {
				alert(items[i].name + ' duplicated item');
				return false;
			}
		}
		return true;
	},
	getApplicationXml: function(appName) {
		var items = this.allItems.values();
		var reorderedItems = new Array(items.length);
		
		//find start, end
		//var sortedItems = new HashMap();
		var index = 1;
		for(var i = 0; i < items.length; i++) {
			if(items[i].itemType == 'start') {
				reorderedItems[0] = items[i];
				//sortedItems.put(i, items[i]);
			} else if(items[i].itemType == 'end') {
				reorderedItems[reorderedItems.length - 1] = items[i];
				//sortedItems.put(i, items[i]);
			} else {
				//sortedItems.put(i, items[i]);
				reorderedItems[index] = items[i];
				index++;
			}
		}
		if(reorderedItems[0] == null) {
			alert('no start');
			return;
		}
		if(reorderedItems[reorderedItems.length - 1] == null || reorderedItems[reorderedItems.length - 1].itemType != 'end') {
			alert('no end');
			return;
		}
		
		if(reorderedItems[0].okTo == null || reorderedItems[0].okTo == "") {
			alert('disconnected from start');
			return;
		}
		
		var conn = jsPlumb.getConnections({source: reorderedItems[0].id, target: reorderedItems[0].okTo});
		if(conn == null || conn.length == 0) {
			alert('disconnected from start');
			return;
		}

		//making xml
		var xml = '<workflow-app name="' + appName + '" xmlns="uri:oozie:workflow:0.3">\n';
		
		for(var i = 0; i < reorderedItems.length; i++) {
			xml += reorderedItems[i].getXml('\t') + '\n';
		}
		
		xml += '</workflow-app>';
		
		return xml;
	},
	getItemPositions: function() {
		var items = this.allItems.values();
		var positions = new Array();
		for(var i = 0; i < items.length; i++) {
			positions.push({ name: items[i].name, top: $("#" + items[i].id).position().top, left: $("#" + items[i].id).position().left });
		}
		
		return positions;
	}
};



var defaultXmls = new HashMap();
defaultXmls.put('decision', '<decision name="Noname">\n  <switch>\n    <case to="Noname">[PREDICATE]</case>\n    <case to="Noname">[PREDICATE]</case>\n    <default to="Noname"/>\n  </switch>\n</decision>');
defaultXmls.put('fork', '<fork name="Noname>\n  <path start="Noname" />\n  <path start="Noname" />\n</fork>');
defaultXmls.put('join', '<join name="Noname" to="Noname" />');
defaultXmls.put('streaming', '<mapper>[MAPPER-PROCESS]</mapper>\n<reducer>[REDUCER-PROCESS]</reducer>\n<record-reader>[RECORD-READER-CLASS]</record-reader>\n<record-reader-mapping>[NAME=VALUE]</record-reader-mapping>\n<env>[NAME=VALUE]</env>');
defaultXmls.put('pipes', '<map>[MAPPER]</map>\n<reduce>[REDUCER]</reducer>\n<inputformat>[INPUTFORMAT]</inputformat>\n<partitioner>[PARTITIONER]</partitioner>\n<writer>[OUTPUTFORMAT]</writer>\n<program>[EXECUTABLE]</program>');

//parent class
function WorkflowItem(nodeType, itemType) {
	this.nodeType = nodeType;	//control, actiom sub-workflow
	this.itemType = itemType;	//start, end, mapreduce, ...
	this.name = 'Noname';
	this.targetDivId = null;
	this.attached = false;
	this.okTo = null;		//id
	this.errorTo = null;	//id
	this.okToName = null;		//name(only for reload from server data)
	this.errorToName = null;	//name(only for reload from server data)
	this.updateMode = false;
	
	var tmpId = null;
	var currentTime = (new Date()).getTime();
	var tmpIndex = 0;
	while(true) {
		tmpId = this.itemType + '_' + (currentTime + tmpIndex);
		if(designManager.allItems.get(tmpId) == null) {
			break;
		} 
		tmpIndex++;
	}
	this.id = tmpId;
	
	this.getXml = function() {
		var xml = "";
		xml += '<' + this.itemType + ' name="' + this.name + '"/>';
		
		return xml;
	};
	
	this.initNextItemId = function() {
		if(this.okToName != null) {
			var item = designManager.findItemByName(this.okToName);
			if(item != null) {
				this.okTo = item.id;
			}
		}
		if(this.errorToName != null) {
			var item = designManager.findItemByName(this.errorToName);
			if(item != null) {
				this.errorTo = item.id;
			}
		}
	};
	
	this.itemConnected = function(targetItem, errorConn) {
	};
	
	this.itemDisconnected = function(targetItem, errorConn) {
	};

	this.removeAllConnection = function() {
		jsPlumb.detachAllConnections(this.id);
	}
	
	this.initItemInfo = function(itemInfo) {
		this.okToName = itemInfo.itemProps['ok'];
		this.errorToName = itemInfo.itemProps['error'];
	};
	
	this.attachTo = function(targetDivId, top, left) {
		var parentThis = this;
		if(this.attached) {
			alert('already attached to ' + this.targetDivId);
			return;
		}
		this.targetDivId = targetDivId;
		
		var shapeClass = 'item-rectangle';
		var anchorPositions = [];
		
		if(this.itemType == "start") {
			shapeClass = "item-circle-start";
		} else if(this.itemType == "end" || this.itemType == "kill") {
			shapeClass = "item-circle";
		} else if(this.itemType == "decision") {
			shapeClass = "item-decision";
		} else if(this.itemType == "join" || this.itemType == "fork") {
			shapeClass = "item-join";
		}
		
		if(this.itemType == "start") {
			anchorPositions.push("BottomCenter");
		} else if(this.itemType == "end" || this.itemType == "kill") {
			anchorPositions.push("TopCenter");
		} else {
			anchorPositions.push("TopCenter");
			anchorPositions.push("BottomCenter");
		}
		
		var showName = true;
		if(this.itemType == "decision") {
			showName = false;
		}
		
		var div = $("<div/>");
		div.attr('id', this.id);
		div.addClass('oozie-item ' + shapeClass);
		
		var bgImage = null;
		if(this.itemType == "hive") {
			bgImage = "hive_bg.jpg";
		} else if(this.itemType == "map-reduce" || this.itemType == "fs") {
			bgImage = "hadoop_bg.jpg";
		} else if(this.itemType == "pig") {
			bgImage = "pig_bg.jpg";
		} else if(this.itemType == "java") {
			bgImage = "java_bg.jpg";
		} else if(this.itemType == "ssh") {
			bgImage = "ssh_bg.jpg";
		} else if(this.itemType == "shell") {
			bgImage = "shell_bg.jpg";
		}
		if(bgImage != null) {
			div.css('background-image', 'url(/resources/images/' + bgImage + ')');
			div.css('background-repeat', 'repeat');
			div.css('filter', 'alpha(opacity=80)');
		}
		
		if(top == null) {
			var divHeight = $("#" + targetDivId).height();
			top = Math.floor(Math.random() * (divHeight - 100)) + 20;
		}
		if(left == null) {
			var divWidth = $("#" + targetDivId).width();
			left = Math.floor(Math.random() * (divWidth - 200)) + 50;
		}
		div.css('top', top + 'px');
		div.css('left', left + 'px');
		
		var innerDivHtml = "";
		innerDivHtml += "<div>";
		innerDivHtml += "	<div>";
		innerDivHtml += "	<table width='100%' height='20px' cellpadding='0' cellspacing='0' border='0'><tr>";
		innerDivHtml += "		<td width='30%' height='20px'></td>";
		innerDivHtml += "		<td width='40%' height='20px'>";
		if(this.itemType == "start") {
			innerDivHtml += "<b>" + this.itemType + "</b>";
		} else if(this.itemType == "decision") {
			//nothing
		} else {
			innerDivHtml += "<span style='white-space: nowrap; overflow: hidden; text-overflow: ellipsis;'>[" + this.itemType + "]</span>";
		}
		innerDivHtml += "		</td>";
		innerDivHtml += "		<td width='30%'>";
		innerDivHtml += "			<div style='float:right'><span class='ui-icon ui-icon-close' id='item-close-" + this.id + "'></span></div>";
		innerDivHtml += "			<div style='float:right'><span class='ui-icon ui-icon-gear' id='item-setting-" + this.id + "'></span></div>";
		innerDivHtml += "			<div style='clear:both'>";
		innerDivHtml += "		</td>";
		innerDivHtml += "	</tr></table>";
		innerDivHtml += "	</div>"

		if(this.itemType == "start" || this.itemType == "decision") {
			//innerDivHtml += "	<div class='item-info'><div class='item-info'><b>" + this.itemType + "</b></div><div class='item-info'> </div>";
		} else {
			innerDivHtml += "	<div class='item-info' style='overflow:hidden;text-overflow:ellipsis;'><span id='" + this.id + "-item-name' style='dispaly:inline-block;font-weight:bold'>" + this.name + "</span></div>";
		}
		innerDivHtml += "</div>";

		div.append(innerDivHtml);
		
		$('#' + targetDivId).append(div);

		//close, setting button event
		$("#item-close-" + this.id).click(function() {
			jsPlumb.detachAllConnections(parentThis.id);
			jsPlumb.removeAllEndpoints(parentThis.id);
			$("#" + parentThis.id).remove();
			designManager.removeItem(parentThis.id);
		});
		
		$("#item-setting-" + this.id).click(function() {
			//parentThis.showConfigXml();
			parentThis.showConfigDialog();
		});
		
		//add end point
		var itemEndpoint = endpoint;
		if(this.itemType == "kill" || this.itemType == "end") {
			itemEndpoint = multiConnEndpoint;
		}
		for(var i = 0; i < anchorPositions.length; i++) {
			if((this.itemType == "decision" || this.itemType == "fork") && anchorPositions[i] == "BottomCenter") {
				//console.log("Add1>" + this.id + anchorPositions[i]);
				jsPlumb.addEndpoint(this.id, { anchor: anchorPositions[i], uuid: this.id + anchorPositions[i] }, multiConnEndpoint );
			} else if((this.itemType == "join" || this.itemType == "join") && anchorPositions[i] == "TopCenter") {
				jsPlumb.addEndpoint(this.id, { anchor: anchorPositions[i], uuid: this.id + anchorPositions[i] }, multiConnEndpoint );
			} else {
				//console.log("Add2>" + this.id + anchorPositions[i]);
				jsPlumb.addEndpoint(this.id, { anchor: anchorPositions[i], uuid: this.id + anchorPositions[i] }, itemEndpoint );
			}
		}
		
		//add error end point
		if(this.isActionItem()) {
			//console.log("Add3>" + this.id + "RightMiddle");
			jsPlumb.addEndpoint(this.id, { anchor: "RightMiddle", uuid: this.id + "RightMiddle" }, errorEndpoint );
		}

		jsPlumb.draggable($("#" + this.id));
		$("#" + this.id).bind('click', function() {
			parentThis.clicked();
		});
		
		this.attached = true;
		
		//designManager.addItem(this);
	};
	
	this.setName = function(name) {
		var item = designManager.findItemByName(name);
		if(item != null && this.id != item.id) {
			alert(name + ' already exists');
			return false;
		}
		this.name = name;
 		$("#" + this.id + "-item-name").text(name);
 		
 		return true;
	};
	
	this.clicked = function() {
		$("#propertyXml").val(this.getXml());
		$("#actionPropertyTab_itemName").val(this.name);
		$("#actionPropertyTab_itemId").val(this.id);
		$("#propertyTabContainer").tabs("select", 2);
	};
};

function MapReduceItem() {
	this.base = WorkflowItem;
	this.base('action', 'map-reduce');
	
	this.name = "mr-noname";
	this.nameNode = "";
	this.jobTracker = "";
	this.prepare = "";
	this.files = "";
	this.configuration = new HashMap();
	this.pipe = "";
	this.streaming = "";
	this.jobType = "normal";
	
	for(var i = 0; i < defaultMrJobProperty.length; i++) {
		this.configuration.put(defaultMrJobProperty[i].name, defaultMrJobProperty[i].value);
	}
	
	this.showConfigDialog = function() {
		$('#currentConfigItemId').val(this.id);
		$('#map-reduceDialog').dialog('option', 'title', 'Config: ' + this.name + '[map-reduce]');
		$('#map-reduceDialog').dialog('open');
		
		$("#map-reduceDialog_name").val(this.name);
		$("#map-reduceDialog_jobtrackerText").val(this.jobTracker);
		$("#map-reduceDialog_namenodeText").val(this.nameNode);
		$("#map-reduceDialog_prepare").val(this.prepare);
		$("#map-reduceDialog_file").val(this.files);
		
		$("#mapReducePropertyTable").jqGrid("clearGridData");
		var keys = this.configuration.keys();
		for(var i = 0; i < keys.length; i++) {
			$("#mapReducePropertyTable").jqGrid('addRowData', keys[i], { name: keys[i], value: this.configuration.get(keys[i]) });
		}
		
		$('input:radio[name="mapReduceJobType"]').filter('[value="' + this.jobType + '"]').attr('checked', 'checked');
		
		$("#map-reduceStreamingXml").val(this.streaming);
		$("#map-reducePipeXml").val(this.pipe);
		
		this.updateMode = true;
	};
	
	this.initItemInfo = function(itemInfo) {
		this.name = itemInfo.name;
		this.okToName = itemInfo.itemProps['ok'];
		this.errorToName = itemInfo.itemProps['error'];

		this.nameNode = itemInfo.itemProps['name-node'];
		this.jobTracker = itemInfo.itemProps['job-tracker'];
		this.files = itemInfo.itemProps['files'];
		this.prepare = itemInfo.itemProps['prepare'];
		this.pipe = itemInfo.itemProps['pipes'];
		if(this.pipe != null && this.pipe != "") {
			this.jobType = "pipe";
		}
		this.streaming = itemInfo.itemProps['streaming'];
		if(this.streaming != null && this.streaming != "") {
			this.jobType = "streaming";
		}
		var confs = itemInfo.itemProps['configuration'];
		this.configuration.clear();
		for(key in confs) {
			this.configuration.put(key, confs[key]);
		}
	};

	this.isActionItem = function() {
		return true;
	};
	
	this.getXml = function(tab) {
		if(tab == null) {
			tab = "";
		}
		var xml = "";
		xml += tab + '<action name="' + this.name + '">\n';
		xml += tab + '	<map-reduce>\n';
		xml += tab + '		<job-tracker>' + this.jobTracker + '</job-tracker>\n';
		xml += tab + '		<name-node>' + this.nameNode + '</name-node>\n';
		
		xml += getFilesXml(this, tab);
		xml += getPrepareXml(this, tab);
		xml += getConfigurationXml(this, tab);
		
		if(this.jobType == "pipe") {
			xml += tab + '		<pipes>\n';
			var pipeItems = this.pipe.split("\n");
			for(var i = 0; i < pipeItems.length; i++) {
				xml += tab + '			' + pipeItems[i] + '\n';
			}
			xml += tab + '		</pipes>\n';
		}
		if(this.jobType == "streaming") {
			xml += tab + '		<streaming>\n';
			var streamingItems = this.streaming.split("\n");
			for(var i = 0; i < streamingItems.length; i++) {
				xml += tab + '			' + streamingItems[i] + '\n';
			}
			xml += tab + '		</streaming>\n';
		}
		
		xml += tab + '	</map-reduce>\n';
		
		xml += getOkXml(this, tab);
		
		xml += tab + '</action>';

		return xml;
	};
};

function HiveItem() {
	this.base = WorkflowItem;
	this.base('action', 'hive');
	
	this.name = "hive-noname";
	this.nameNode = "";
	this.jobTracker = "";
	this.prepare = "";
	this.query = "";
	this.queryFile = "";
	this.params = null;
	this.files = "";
	this.configuration = new HashMap();
	
	this.configuration.put('oozie.hive.defaults', '');
	
	this.setLibrary = function() {
		/*
		var libFiles = workflowUtil.getCommonLibFiles('hive');
		
		if(libFiles != null) {
			var delim = "";
			var files = "";
			for(var i = 0; i < libFiles.length; i++) {
				if(workflowUtil.endsWith(libFiles[i], 'hive-site.xml')) {
					files += delim + "<job-xml>" + libFiles[i] + "</job-xml>";
					delim = "\n";
					break;
				} 
			}
			for(var i = 0; i < libFiles.length; i++) {
				if(workflowUtil.endsWith(libFiles[i], 'hive-default.xml')) {
					this.configuration.put('oozie.hive.defaults', libFiles[i]);
				} else if(workflowUtil.endsWith(libFiles[i], 'hive-site.xml')) {
				} else {
					files += delim + "<file>" + libFiles[i] + "</file>";
					delim = "\n";
				}
			}

			this.files = files;
		}
		*/
	};
	
	this.saveQueryFile = function(appName) {
		if(this.query == null || this.query == "" || this.queryFile == null || this.queryFile == "") {
			return;
		}
		var self = this;
		$.ajax({
			url: APPLICATION_CONTEXT + 'workflow/saveQuery.do', 
			type: 'POST',
			async: false,
			data: {
				appName: appName,
				queryFile: self.queryFile,
				query: self.query
			},
			success: function(result) {
				if(!result.success) {
					alert(result.msg);
					return;
				} else {
					alert('query saved to [' + result.data + ']');
				}
			}
		});	
	};
	
	this.showConfigDialog = function() {
		if($("#appName").val() == null || $("#appName").val() == "") {
			alert('no app name');
			return;
		}
		$('#currentConfigItemId').val(this.id);
		$('#queryActionDialog_prefix').val('hive');
		$('#queryActionDialog').dialog('option', 'title', 'Config: ' + this.name + '[hive]');
		$('#queryActionDialog').dialog('open');
		
		$("#queryActionDialog_name").val(this.name);
		$("#queryActionDialog_jobtrackerText").val(this.jobTracker);
		$("#queryActionDialog_namenodeText").val(this.nameNode);
		$("#queryActionDialog_prepare").val(this.prepare);
		$("#queryActionDialog_param").val(this.params);
		$("#queryActionDialog_file").val(this.files);

		if(this.queryFile == null || this.queryFile == "" || this.queryFile == undefined) {
			$("#queryActionDialog_queryFile").val('script.q');
		} else {
			$("#queryActionDialog_queryFile").val(this.queryFile);
			$("#queryActionDialog_query").val(workflowUtil.getQueryInFile(this.queryFile, $("#appName").val()));
		}
		
		$("#queryActionDialogPropertyTable").jqGrid("clearGridData");
		var keys = this.configuration.keys();
		for(var i = 0; i < keys.length; i++) {
			$("#queryActionDialogPropertyTable").jqGrid('addRowData', keys[i], { name: keys[i], value: this.configuration.get(keys[i]) });
		}
		
		$("#saveHivePropertyName").val('');
		$("#saveHivePropertyValue").val('');

		this.updateMode = true;
	};
	
	this.initItemInfo = function(itemInfo) {
		this.name = itemInfo.name;
		this.okToName = itemInfo.itemProps['ok'];
		this.errorToName = itemInfo.itemProps['error'];

		this.nameNode = itemInfo.itemProps['name-node'];
		this.jobTracker = itemInfo.itemProps['job-tracker'];

		var confs = itemInfo.itemProps['configuration'];
		this.configuration.clear();
		for(key in confs) {
			this.configuration.put(key, confs[key]);
		}
		this.prepare = itemInfo.itemProps['prepare'];
		this.params = itemInfo.itemProps['param'];
		this.queryFile = itemInfo.itemProps['script'];
		this.files = itemInfo.itemProps['files'];
	};

	this.isActionItem = function() {
		return true;
	};
	
	this.getXml = function(tab) {
		if(tab == null) {
			tab = "";
		}
		var xml = "";
		xml += tab + '<action name="' + this.name + '">\n';
		xml += tab + '	<hive xmlns="uri:oozie:hive-action:0.2">\n';
		xml += tab + '		<job-tracker>' + this.jobTracker + '</job-tracker>\n';
		xml += tab + '		<name-node>' + this.nameNode + '</name-node>\n';

		//var itemOrder = ["job-tracker", "name-node", "prepare", "job-xml", "configuration", "script", "param" ,"file", "archive"];
		
		xml += getPrepareXml(this, tab);
		xml += getFilesXml(this, tab, "job-xml");
		xml += getConfigurationXml(this, tab);

		xml += tab + '		<script>' + this.queryFile + '</script>\n';

		if(this.params != null) {
			var paramItems = this.params.split("\n");
			for(var i = 0; i < paramItems.length; i++) {
				if(paramItems[i].trim().length > 0) {
					xml += tab + '		' + paramItems[i] + '\n';
				}
			}
		}
		xml += getFilesXml(this, tab, "file");
		xml += getFilesXml(this, tab, "archive");

		xml += tab + '	</hive>\n';
		
		xml += getOkXml(this, tab);
		
		xml += tab + '</action>';

		return xml;
	};
};

function PigItem() {
	this.base = WorkflowItem;
	this.base('action', 'pig');
	
	this.name = "pig-noname";
	this.nameNode = "";
	this.jobTracker = "";
	this.prepare = "";
	this.query = "";
	this.queryFile = "";
	this.params = "";
	this.files = "";
	this.configuration = new HashMap();
	
	this.saveQueryFile = function(appName) {
		if(this.query == null || this.query == "" || this.queryFile == null || this.queryFile == "") {
			return;
		}
		var self = this;
		$.ajax({
			url: APPLICATION_CONTEXT + 'workflow/saveQuery.do', 
			type: 'POST',
			async: false,
			data: {
				appName: appName,
				queryFile: self.queryFile,
				query: self.query
			},
			success: function(result) {
				if(!result.success) {
					alert(result.msg);
					return;
				} else {
					alert('query saved to [' + result.data + ']');
				}
			}
		});	
	};
	
	this.showConfigDialog = function() {
		if($("#appName").val() == null || $("#appName").val() == "") {
			alert('no app name');
			return;
		}
		$('#currentConfigItemId').val(this.id);
		$('#queryActionDialog_prefix').val('pig');
		$('#queryActionDialog').dialog('option', 'title', 'Config: ' + this.name + '[pig]');
		$('#queryActionDialog').dialog('open');
		
		$("#queryActionDialog_name").val(this.name);
		$("#queryActionDialog_jobtrackerText").val(this.jobTracker);
		$("#queryActionDialog_namenodeText").val(this.nameNode);
		$("#queryActionDialog_prepare").val(this.prepare);
		$("#queryActionDialog_param").val(this.params);
		$("#queryActionDialog_file").val(this.files);
		
		if(this.queryFile == null || this.queryFile == "" || this.queryFile == undefined) {
			$("#queryActionDialog_queryFile").val('script.pig');
		} else {
			$("#queryActionDialog_queryFile").val(this.queryFile);
			$("#queryActionDialog_query").val(workflowUtil.getQueryInFile(this.queryFile, $("#appName").val()));
		}
		
		$("#queryActionDialogPropertyTable").jqGrid("clearGridData");
		var keys = this.configuration.keys();
		for(var i = 0; i < keys.length; i++) {
			$("#queryActionDialogPropertyTable").jqGrid('addRowData', keys[i], { name: keys[i], value: this.configuration.get(keys[i]) });
		}
		
		$("#queryActionDialogPropertyName").val('');
		$("#queryActionDialogPropertyValue").val('');
		
		this.updateMode = true;
	};
	
	this.initItemInfo = function(itemInfo) {
		this.name = itemInfo.name;
		this.okToName = itemInfo.itemProps['ok'];
		this.errorToName = itemInfo.itemProps['error'];

		this.nameNode = itemInfo.itemProps['name-node'];
		this.jobTracker = itemInfo.itemProps['job-tracker'];

		var confs = itemInfo.itemProps['configuration'];
		this.configuration.clear();
		for(key in confs) {
			this.configuration.put(key, confs[key]);
		}
		this.prepare = itemInfo.itemProps['prepare'];
		this.params = itemInfo.itemProps['param'];
		this.queryFile = itemInfo.itemProps['script'];
		this.files = itemInfo.itemProps['files'];
	};

	this.isActionItem = function() {
		return true;
	};
	
	this.getXml = function(tab) {
		if(tab == null) {
			tab = "";
		}
		var xml = "";
		xml += tab + '<action name="' + this.name + '">\n';
		xml += tab + '	<pig>\n';
		xml += tab + '		<job-tracker>' + this.jobTracker + '</job-tracker>\n';
		xml += tab + '		<name-node>' + this.nameNode + '</name-node>\n';

		xml += getFilesXml(this, tab);
		xml += getPrepareXml(this, tab);
		xml += getConfigurationXml(this, tab);

		xml += tab + '		<script>' + this.queryFile + '</script>\n';
		

		if(this.params != null) {
			var paramItems = this.params.split("\n");
			for(var i = 0; i < paramItems.length; i++) {
				if(paramItems[i].trim().length > 0) {
					xml += tab + '		' + paramItems[i] + '\n';
				}
			}
		}

		xml += tab + '	</pig>\n';
		
		xml += getOkXml(this, tab);
		
		xml += tab + '</action>';

		return xml;
	};
};

function JavaItem() {
	this.base = WorkflowItem;
	this.base('action', 'java');
	
	this.name = "java-noname";
	this.nameNode = "";
	this.jobTracker = "";
	this.mainClass = "";
	this.javaOpts = "";
	this.args = "";
	this.files = "";
	this.captureOutput = false;
	this.configuration = new HashMap();
	
	this.showConfigDialog = function() {
		if($("#appName").val() == null || $("#appName").val() == "") {
			alert('no app name');
			return;
		}
		$('#currentConfigItemId').val(this.id);
		$('#javaDialog').dialog('option', 'title', 'Config: ' + this.name + '[java]');
		$('#javaDialog').dialog('open');
		
		$("#javaDialog_name").val(this.name);
		$("#javaDialog_jobtrackerText").val(this.jobTracker);
		$("#javaDialog_namenodeText").val(this.nameNode);
		$("#javaDialog_mainClass").val(this.mainClass);
		$("#javaDialog_javaOpts").val(this.javaOpts);
		$("#javaDialog_args").val(this.args);
		$("#javaDialog_file").val(this.files);

		$("#javaDialogPropertyTable").jqGrid("clearGridData");
		var keys = this.configuration.keys();
		for(var i = 0; i < keys.length; i++) {
			$("#javaDialogPropertyTable").jqGrid('addRowData', keys[i], { name: keys[i], value: this.configuration.get(keys[i]) });
		}
		
		$("#javaDialog_captureOutput").attr('checked', this.captureOutput);
		
		$("#javaDialogPropertyName").val('');
		$("#javaDialogPropertyValue").val('');
		
		this.updateMode = true;
	};
	
	this.initItemInfo = function(itemInfo) {
		this.name = itemInfo.name;
		this.okToName = itemInfo.itemProps['ok'];
		this.errorToName = itemInfo.itemProps['error'];

		this.nameNode = itemInfo.itemProps['name-node'];
		this.jobTracker = itemInfo.itemProps['job-tracker'];

		var confs = itemInfo.itemProps['configuration'];
		this.configuration.clear();
		for(key in confs) {
			this.configuration.put(key, confs[key]);
		}
		this.mainClass = itemInfo.itemProps['main-class'];
		this.javaOpts = itemInfo.itemProps['java-opts'];
		this.args = itemInfo.itemProps['arg'];
		this.captureOutput = itemInfo.itemProps['capture-output'];
		this.files = itemInfo.itemProps['files'];
		if(this.captureOutput == null || this.captureOutput == "" || this.captureOutput == undefined) {
			this.captureOutput = false;
		}
	};

	this.isActionItem = function() {
		return true;
	};
	
	this.getXml = function(tab) {
		if(tab == null) {
			tab = "";
		}
		var xml = "";
		xml += tab + '<action name="' + this.name + '">\n';
		xml += tab + '	<java>\n';
		if(this.jobTracker != null && this.jobTracker != "") {
			xml += tab + '		<job-tracker>' + this.jobTracker + '</job-tracker>\n';
		}
		if(this.nameNode != null && this.nameNode != "") {
			xml += tab + '		<name-node>' + this.nameNode + '</name-node>\n';
		}

		xml += getFilesXml(this, tab);
		xml += getConfigurationXml(this, tab);

		xml += tab + '		<main-class>' + this.mainClass + '</main-class>\n';
		xml += tab + '		<java-opts>' + this.javaOpts + '</java-opts>\n';

		if(this.args != null) {
			var argItems = this.args.split("\n");
			for(var i = 0; i < argItems.length; i++) {
				if(argItems[i].trim().length > 0) {
					xml += tab + '		' + argItems[i] + '\n';
				}
			}
		}
		if(this.captureOutput) {
			xml += tab + '		<capture-output/>\n';
		}

		xml += tab + '	</java>\n';
		
		xml += getOkXml(this, tab);
		
		xml += tab + '</action>';

		return xml;
	};
};

function SshItem() {
	this.base = WorkflowItem;
	this.base('action', 'ssh');
	
	this.name = "ssh-noname";
	this.host = null;
	this.command = null;
	this.args = null;
	this.captureOutput = false;
	
	this.showConfigDialog = function() {
		if($("#appName").val() == null || $("#appName").val() == "") {
			alert('no app name');
			return;
		}
		$('#currentConfigItemId').val(this.id);
		$('#sshDialog').dialog('option', 'title', 'Config: ' + this.name + '[ssh]');
		$('#sshDialog').dialog('open');
		
		$("#sshDialog_name").val(this.name);
		$("#sshDialog_host").val(this.host);
		$("#sshDialog_command").val(this.command);
		$("#sshDialog_args").val(this.args);

		$("#sshDialog_captureOutput").attr('checked', true);

		$("#sshDialog_argsText").val('');
		
		this.updateMode = true;
	};
	
	this.initItemInfo = function(itemInfo) {
		this.name = itemInfo.name;
		this.okToName = itemInfo.itemProps['ok'];
		this.errorToName = itemInfo.itemProps['error'];

		this.host = itemInfo.itemProps['host'];
		this.command = itemInfo.itemProps['command'];
		this.args = itemInfo.itemProps['args'];
		
		this.captureOutput = itemInfo.itemProps['capture-output'];
		if(this.captureOutput == null || this.captureOutput == "" || this.captureOutput == undefined) {
			this.captureOutput = false;
		}
	};

	this.isActionItem = function() {
		return true;
	};
	
	this.getXml = function(tab) {
		if(tab == null) {
			tab = "";
		}
		var xml = "";
		xml += tab + '<action name="' + this.name + '">\n';
		xml += tab + '	<ssh>\n';
		xml += tab + '		<host>' + this.host + '</host>\n';
		xml += tab + '		<command>' + this.command + '</command>\n';

		if(this.args != null) {
			var argItems = this.args.split("\n");
			for(var i = 0; i < argItems.length; i++) {
				if(argItems[i].trim().length > 0) {
					xml += tab + '		' + argItems[i] + '\n';
				}
			}
		}
		if(this.captureOutput) {
			xml += tab + '		<capture-output/>\n';
		}

		xml += tab + '	</ssh>\n';
		
		xml += getOkXml(this, tab);
		
		xml += tab + '</action>';

		return xml;
	};
};

function FsItem() {
	this.base = WorkflowItem;
	this.base('action', 'fs');
	this.name = "fs-noname";
	
	this.fsCommands = [];
	
	/*
	<delete path='hdfs://foo:9000/usr/tucu/temp-data'/>
    <mkdir path='archives/${wf:id()}'/>
    <move source='${jobInput}' target='archives/${wf:id()}/processed-input'/>
    <chmod path='${jobOutput}' permissions='-rwxrw-rw-' dir-files='true'/>	
    */
    
	this.showConfigDialog = function() {
		if($("#appName").val() == null || $("#appName").val() == "") {
			alert('no app name');
			return;
		}
		$('#currentConfigItemId').val(this.id);
		$('#fsDialog').dialog('option', 'title', 'Config: ' + this.name + '[fs]');
		$('#fsDialog').dialog('open');
		
		$("#fsDialog_name").val(this.name);

		$("#fsDialogCommandTable").jqGrid("clearGridData");
		
		var currentTime = (new Date()).getTime();
		
		for(var i = 0; i < this.fsCommands.length; i++) {
			$("#fsDialogCommandTable").jqGrid('addRowData', currentTime + i, { command: fsCommands[i] });
		}
		
		$("#fsDialog_deleteDiv").hide();
		$("#fsDialog_moveDiv").hide();
		$("#fsDialog_chmodDiv").hide();

		this.updateMode = true;
	};
	
	this.initItemInfo = function(itemInfo) {
		this.name = itemInfo.name;
		this.okToName = itemInfo.itemProps['ok'];
		this.errorToName = itemInfo.itemProps['error'];

		var commands = itemInfo.itemProps['fsCommands'];
		this.fsCommands = [];
		for(var i = 0; i < commands.length; i++) {
			this.fsCommand = commands[i]; 
		}
	};

	this.isActionItem = function() {
		return true;
	};
	
	this.getXml = function(tab) {
		if(tab == null) {
			tab = "";
		}
		var xml = "";
		xml += tab + '<action name="' + this.name + '">\n';
		xml += tab + '	<fs>\n';

		if(this.fsCommands != null) {
			for(var i = 0; i < this.fsCommands.length; i++) {
				xml += tab + '		' + fsCommands[i] + '\n';
			}
		}

		xml += tab + '	</fs>\n';
		
		xml += getOkXml(this, tab);
		
		xml += tab + '</action>';

		return xml;
	};
    
};

function ShellItem() {
	this.base = WorkflowItem;
	this.base('action', 'shell');
	
	this.name = "shell-noname";
	this.nameNode = null;
	this.jobTracker = null;
	this.prepare = null;
	this.captureOutput = false;
	this.exec = null;
	this.argment = null;
	this.envVar = null;
	this.configuration = new HashMap();
	
	this.showConfigDialog = function() {
		if($("#appName").val() == null || $("#appName").val() == "") {
			alert('no app name');
			return;
		}
		$('#currentConfigItemId').val(this.id);
		$('#shellDialog').dialog('option', 'title', 'Config: ' + this.name + '[shell]');
		$('#shellDialog').dialog('open');
		
		$("#shellDialog_name").val(this.name);
		$("#shellDialog_jobtrackerText").val(this.jobTracker);
		$("#shellDialog_namenodeText").val(this.nameNode);
		$("#shellDialog_prepare").val(this.prepare);
		$("#shellDialog_exec").val(this.exec);
		$("#shellDialog_argument").val(this.argument);
		$("#shellDialog_envVar").val(this.envVar);

		$("#shellDialogPropertyTable").jqGrid("clearGridData");
		var keys = this.configuration.keys();
		for(var i = 0; i < keys.length; i++) {
			$("#shellDialogPropertyTable").jqGrid('addRowData', keys[i], { name: keys[i], value: this.configuration.get(keys[i]) });
		}
		
		$("#shellDialog_captureOutput").attr('checked', this.captureOutput);

		$("#shellPropertyName").val('');
		$("#shellPropertyValue").val('');
		
		this.updateMode = true;
	};
	
	this.initItemInfo = function(itemInfo) {
		this.name = itemInfo.name;
		this.okToName = itemInfo.itemProps['ok'];
		this.errorToName = itemInfo.itemProps['error'];

		this.nameNode = itemInfo.itemProps['name-node'];
		this.jobTracker = itemInfo.itemProps['job-tracker'];

		var confs = itemInfo.itemProps['configuration'];
		this.configuration.clear();
		for(key in confs) {
			this.configuration.put(key, confs[key]);
		}
		this.exec = itemInfo.itemProps['exec'];
		this.prepare = itemInfo.itemProps['prepare'];
		this.argument = itemInfo.itemProps['argument'];
		this.envVar = itemInfo.itemProps['env-var'];
		
		this.captureOutput = itemInfo.itemProps['capture-output'];
		if(this.captureOutput == null || this.captureOutput == "" || this.captureOutput == undefined) {
			this.captureOutput = false;
		}
	};

	this.isActionItem = function() {
		return true;
	};
	
	this.getXml = function(tab) {
		if(tab == null) {
			tab = "";
		}
		var xml = "";
		xml += tab + '<action name="' + this.name + '">\n';
		xml += tab + '	<shell xmlns="uri:oozie:shell-action:0.1">\n';
		xml += tab + '		<job-tracker>' + this.jobTracker + '</job-tracker>\n';
		xml += tab + '		<name-node>' + this.nameNode + '</name-node>\n';
		
		xml += getPrepareXml(this, tab);
		xml += getConfigurationXml(this, tab);
		
		xml += tab + '		<exec>' + this.exec + '</exec>\n';
		

		if(this.argument != null) {
			var argItems = this.argument.split("\n");
			for(var i = 0; i < argItems.length; i++) {
				if(argItems[i].trim().length > 0) {
					xml += tab + '		' + argItems[i] + '\n';
				}
			}
		}

		if(this.envVar != null) {
			var envItems = this.envVar.split("\n");
			for(var i = 0; i < envItems.length; i++) {
				if(envItems[i].trim().length > 0) {
					xml += tab + '		' + envItems[i] + '\n';
				}
			}
		}
		if(this.captureOutput) {
			xml += tab + '		<capture-output/>\n';
		}

		xml += tab + '	</shell>\n';
		
		xml += getOkXml(this, tab);
		
		xml += tab + '</action>';

		return xml;
	};
}

function UserDefinedItem() {
	this.base = WorkflowItem;
	this.base('action', 'user-defined');
	
	this.name = "noname";
	this.actionXml = "";
	
	this.showConfigDialog = function() {
		if($("#appName").val() == null || $("#appName").val() == "") {
			alert('no app name');
			return;
		}
		$('#currentConfigItemId').val(this.id);
		$('#userDefineDialog').dialog('option', 'title', 'Config: ' + this.name);
		$('#userDefineDialog').dialog('open');
		
		$("#userDefineDialog_name").val(this.name);
		$("#userDefineDialog_actionXml").val(this.actionXml);
		
		this.updateMode = true;
	};
	
	this.initItemInfo = function(itemInfo) {
		this.name = itemInfo.name;
		this.okToName = itemInfo.itemProps['ok'];
		this.errorToName = itemInfo.itemProps['error'];

		this.actionXml = itemInfo.itemProps['actionXml'];
	};

	this.isActionItem = function() {
		return true;
	};
	
	this.getXml = function(tab) {
		if(tab == null) {
			tab = "";
		}
		var xml = "";
		xml += tab + '<action name="' + this.name + '">\n';
		xml += tab + this.actionXml + '\n';
		
		xml += getOkXml(this, tab);
		
		xml += tab + '</action>';

		return xml;
	};	
}

function StartItem() {
	this.base = WorkflowItem;
	this.base('control', 'start');
	this.name = "start";
	
	this.showConfigDialog = function() {
		//$('#currentConfigItemId').val(this.id);
		//$('#map-reduceDialog').dialog('option', 'title', 'Config: ' + this.name + '[map-reduce]');
		//$('#map-reduceDialog').dialog('open');
	};
	
	this.initItemInfo = function(itemInfo) {
		this.okToName = itemInfo.itemProps['to'];
	};
	
	this.getXml = function(tab) {
		var xml = "";
		if(tab == null) {
			tab = "";
		}
		
		if(this.okTo == null || designManager.getItem(this.okTo) == null) {
			xml = tab + '<start to=""/>';
		} else {
			xml = tab + '<start to="' + designManager.getItem(this.okTo).name + '"/>';
		}
		return xml;
	};
	
	this.isActionItem = function() {
		return false;
	};

};

function EndItem(itemType) {
	this.base = WorkflowItem;
	this.base('control', itemType);
	this.name = itemType;
	
	this.showConfigDialog = function() {
		$('#currentConfigItemId').val(this.id);
		$('#endDialog_name').val(this.name);
		$('#endDialog').dialog('option', 'title', 'Config: ' + this.name);
		$('#endDialog').dialog('open');
	};
	
	this.getXml = function(tab) {
		var xml = "";
		if(tab == null) {
			tab = "";
		}
		
		xml += tab + '<end name="' + this.name + '"/>';
		
		return xml;
	};	
	
	this.isActionItem = function() {
		return false;
	};
};

function KillItem(itemType) {
	this.base = WorkflowItem;
	this.base('control', itemType);
	this.name = itemType;
	this.message = "";
	
	this.initItemInfo = function(itemInfo) {
		this.message = itemInfo.itemProps['message'];
	};
	
	this.showConfigDialog = function() {
		$('#currentConfigItemId').val(this.id);
		$('#killDialog_name').val(this.name);
		$('#killDialog_message').val(this.message);
		$('#killDialog').dialog('option', 'title', 'Config: ' + this.itemType);
		$('#killDialog').dialog('open');
	};
	
	this.getXml = function(tab) {
		var xml = "";
		if(tab == null) {
			tab = "";
		}
		
		xml += tab + '<kill name="' + this.name + '">\n';
		xml += tab + '	<message>' + this.message + '</message>\n';
		xml += tab + '</kill>';
		return xml;
	};	
	
	this.isActionItem = function() {
		return false;
	};
};

function DecisionItem() {
	this.base = WorkflowItem;
	this.base('control', 'decision');
	this.name = 'decision';
	this.caseMap = new HashMap();
	
	this.initItemInfo = function(itemInfo) {
		for(caseTo in itemInfo.itemProps) {
			var value = itemInfo.itemProps[caseTo];
			var targetItem = designManager.findItemByName(caseTo);
			this.caseMap.put(targetItem.id, {toId: targetItem.id, toName: targetItem.name, condition: value});
		}
	};
	
	this.reloadConnection = function() {
		var self = this;
		this.removeAllConnection();
		var caseMapKeys = this.caseMap.keys();
		for(var i = 0; i < caseMapKeys.length; i++) {
			var connection = jsPlumb.connect({uuids:[this.id + "BottomCenter", caseMapKeys[i] + "TopCenter"]});
			connection.bind("click", function(conn) {
				self.showConditionDialogById(conn.targetId);
			});
		}
	};
	
	this.itemConnected = function(targetItem, errorConn) {
		this.caseMap.put(targetItem.id, {toId: targetItem.id, toName: targetItem.name, condition: ''});
	};
	
	this.itemDisconnected = function(targetItem, errorConn) {
		this.caseMap.remove(targetItem.id);
	};
	
	this.setCondition = function(targetItem, condition) {
		this.caseMap.put(targetItem.id, {toId: targetItem.id, toName: targetItem.name, condition: condition});
	}
	
	this.showConditionDialogById = function(targetId) {
		this.showConditionDialog(designManager.getItem(targetId));
	}
	
	this.showConditionDialog = function(targetItem) {
		var targetValue = this.caseMap.get(targetItem.id);
		var condition = (targetValue != null) ? targetValue.condition : "";
		$("#decisionConditionDialog_condition").val(condition);
		$("#decisionConditionDialog_sourceId").val(this.id);
		$("#decisionConditionDialog_targetId").val(targetItem.id);
		
		$("#decisionConditionDialog").dialog('open');
	}
	
	this.showConfigDialog = function() {
		$('#currentConfigItemId').val(this.id);
		
		var items = designManager.allItems.values();
		
		$('#decisionDialog_caseTo').empty();
		for(var i = 0; i < items.length; i++) {
			if(items[i].name != this.name && items[i].itemType != 'start') {
				$('#decisionDialog_caseTo').append('<option value="' + items[i].id + '">' + items[i].name + '</option>');
			}
		}

		$('#decisionCaseTable').jqGrid("clearGridData");

		var caseMapKeys = this.caseMap.keys();
		for(var i = 0; i < caseMapKeys.length; i++) {
			var value = this.caseMap.get(caseMapKeys[i]);
			$("#decisionCaseTable").jqGrid('addRowData', caseMapKeys[i], {toName: designManager.getItem(value.toId).name, toId: value.toId, condition: value.condition});
		}
		
		$("#decisionDialog_name").val(this.name);
		$("#decisionDialog_caseTo").val('');
		$("#decisionDialog_condition").val('');
		$("#decisionDialog_default").attr('checked', false);
		
		$('#decisionDialog').dialog('option', 'title', 'Config: ' + this.itemType);
		$('#decisionDialog').dialog('open');
	};
	
	this.getXml = function(tab) {
		var xml = "";
		if(tab == null) {
			tab = "";
		}
		
		xml += tab + '<decision name="' + this.name + '">\n';
		xml += tab + '	<switch>\n';
		var caseMapKeys = this.caseMap.keys();
		var defaultTo = null;
		for(var i = 0; i < caseMapKeys.length; i++) {
			var value = this.caseMap.get(caseMapKeys[i]);
			if(value.condition == "default") {
				defaultTo = value.toName;
			} else {
				xml += tab + '		<case to="' + designManager.getItem(caseMapKeys[i]).name + '">' + value.condition + '</case>\n';
			}
		}
		if(defaultTo != null) {
			xml += tab + '		<default to="' + defaultTo + '"/>\n';	
		}
		xml += tab + '	</switch>\n';
		xml += tab + '</decision>';
		return xml;
	};	
	
	this.isActionItem = function() {
		return false;
	};
};

function ForkItem() {
	this.base = WorkflowItem;
	this.base('control', 'fork');
	this.name = 'fork';
	this.pathMap = new HashMap();
	
	this.initItemInfo = function(itemInfo) {
		for(pathStart in itemInfo.itemProps) {
			var targetItem = designManager.findItemByName(pathStart);
			this.pathMap.put(targetItem.id, targetItem.name);
		}
	};

	this.itemConnected = function(targetItem, errorConn) {
		this.pathMap.put(targetItem.id, targetItem.name);
	};
	
	this.itemDisconnected = function(targetItem, errorConn) {
		this.pathMap.remove(targetItem.id);
	};

	this.showConfigDialog = function() {
		$('#currentConfigItemId').val(this.id);
		$('#forkDialog').dialog('option', 'title', 'Config: ' + this.itemType);
		$('#forkDialog').dialog('open');
	};
	
	this.getXml = function(tab) {
		var xml = "";
		if(tab == null) {
			tab = "";
		}
		
		xml += tab + '<fork name="' + this.name + '">\n';
		var keys = this.pathMap.keys();
		for(var i = 0; i < keys.length; i++) {
			xml += tab + '	<path start="' + designManager.getItem(keys[i]).name + '"/>\n';
		}
		xml += tab + '</fork>';
		return xml;
	};	
	
	this.isActionItem = function() {
		return false;
	};
};

function JoinItem() {
	this.base = WorkflowItem;
	this.base('control', 'join');
	this.name = 'join';
	
	this.initItemInfo = function(itemInfo) {
		this.okToName = itemInfo.itemProps['to'];
		this.okTo = designManager.findItemByName(this.okToName).id;
	};
	
	this.showConfigDialog = function() {
		$('#currentConfigItemId').val(this.id);
		$('#joinDialog').dialog('option', 'title', 'Config: ' + this.itemType);
		$('#joinDialog').dialog('open');
	};
	
	this.getXml = function(tab) {
		var xml = "";
		if(tab == null) {
			tab = "";
		}
		
		xml += tab + '<join name="' + this.name + '" to="' + designManager.getItem(this.okTo).name + '"/>';
		return xml;
	};	
	
	this.isActionItem = function() {
		return false;
	};
};

function getOkXml(item, tab) {
	var xml = '';
	
	if(item.okTo == null || designManager.getItem(item.okTo) == null) {
		xml += tab + '	<ok to=""/>\n';
	} else {
		xml += tab + '	<ok to="' + designManager.getItem(item.okTo).name + '"/>\n';
	}
	
	if(item.errorTo != null && designManager.getItem(item.errorTo) != null) {
        xml += tab + '	<error to="' + designManager.getItem(item.errorTo).name + '"/>\n';
	}	
	
	return xml;
}

function getFilesXml(item, tab, tag) {
	var xml = '';
	if(item.files != null && item.files != "") {
		var filesItems = item.files.split("\n");
		for(var i = 0; i < filesItems.length; i++) {
			if(tag != null) {
				//console.log(filesItems[i] + "," + tag + "," + (filesItems[i].indexOf(tag) == 0));
				if(filesItems[i].indexOf('<' + tag + '>') == 0) {
					xml += tab + '		' + filesItems[i] + '\n';
				}
			} else {
				xml += tab + '		' + filesItems[i] + '\n';
			}
		}
	}
	return xml;
}

function getConfigurationXml(item, tab) {
	var xml = '';
	if(item.configuration == null || item.configuration.size() == 0) {
		return xml;
	}
	xml += tab + '		<configuration>\n';
	var confNames = item.configuration.keys();
	for(var i = 0; i < confNames.length; i++) {
		xml += tab + '			<property>\n';
		xml += tab + '				<name>' + confNames[i] + '</name>\n';
		xml += tab + '				<value>' + item.configuration.get(confNames[i]) + '</value>\n';
		xml += tab + '			</property>\n';
	}
	xml += tab + '		</configuration>\n';
	
	return xml;
}

function getPrepareXml(item, tab) {
	var xml = '';
	if(item.prepare == null || item.prepare == "") {
		return xml;
	}
	xml += tab + '		<prepare>\n';
	
	if(item.prepare != null) {
		var prepareItems = item.prepare.split("\n");
		for(var i = 0; i < prepareItems.length; i++) {
			if(prepareItems[i].trim().length > 0) {
				xml += tab + '			' + prepareItems[i] + '\n';
			}
		}
	}
	xml += tab + '		</prepare>\n';
	
	return xml;
}

var jsPlumbWorkflow = {
	init : function() {			
		var color = "gray";

		jsPlumb.importDefaults({
			HoverPaintStyle : {strokeStyle:"#ec9f2e" },
			DragOptions : { cursor: 'pointer', zIndex:2000 },
			EndpointHoverStyle : {fillStyle:"#ec9f2e" },
			ConnectionOverlays : [
				[ "Arrow", { location:1.0 } ],
				[ "Label", { 
					location:0.1,
					id:"label",
					cssClass:"aLabel"
				}]
			]
		});
	}
};

var elFunctions = [ ["String firstNotNull(String value1, String value2)", "It returns the first not null value, or null if both are null."],
                    ["String concat(String s1, String s2)", "It returns the concatenation of 2 strings. A string with null value is considered as an empty string."],
                    ["String trim(String s)", "It returns the trimmed value of the given string. A string with null value is considered as an empty string."],
                    ["String urlEncode(String s)", "It returns the URL UTF-8 encoded value of the given string. A string with null value is considered as an empty string."],
                    ["String timestamp()", "It returns the UTC current date and time in W3C format down to the second (YYYY-MM-DDThh:mm:ss.sZ). I.e.: 1997-07-16T19:20:30.45Z"],
                    ["String wf:id()", "It returns the workflow job ID for the current workflow job."],
                    ["String wf:name()", "It returns the workflow application name for the current workflow job."],
                    ["String wf:appPath()", "It returns the workflow application path for the current workflow job."],
                    ["String wf:conf(String name)", "It returns the value of the workflow job configuration property for the current workflow job, or an empty string if undefined."],
                    ["String wf:user()", "It returns the user name that started the current workflow job."],
                    ["String wf:group()", "It returns the group name for the current workflow job."],
                    ["String wf:callback(String stateVar)", "It returns the callback URL for the current workflow action node"],
                    ["String wf:transition(String node)", "It returns the transition taken by the specified workflow action node"],
                    ["String wf:lastErrorNode()", "It returns the name of the last workflow action node that exit with an ERROR exit state"],
                    ["String wf:errorCode(String node)", "It returns the error code for the specified action node"],
                    ["String wf:errorMessage(String message)", "It returns the error message for the specified action node"],
                    ["int wf:run()", "It returns the run number for the current workflow job"],
                    ["Map wf:actionData(String node)", "This function is only applicable to action nodes that produce output data on completion."],
                    ["int wf:actionExternalId(String node)", "It returns the external Id for an action node"],
                    ["int wf:actionTrackerUri(String node)", "It returns the tracker URIfor an action node"],
                    ["int wf:actionExternalStatus(String node)", "It returns the external status for an action node"],
                    ["RECORDS", "Hadoop record counters group name."],
                    ["MAP_IN", "Hadoop mapper input records counter name."],
                    ["MAP_OUT","Hadoop mapper output records counter name."],
                    ["REDUCE_IN", "Hadoop reducer input records counter name."],
                    ["REDUCE_OUT", "Hadoop reducer input record counter name."],
                    ["GROUPS", "1024 * Hadoop mapper/reducer record groups counter name."],
                    ["Map<String, Map<String, Long>> hadoop:counters(String node)", "It returns the counters for a job submitted by a Hadoop action node."],
                    ["boolean fs:exists(String path)", "It returns true or false depending if the specified path URI exists or not."],
                    ["boolean fs:isDir(String path)", "It returns true if the specified path URI exists and it is a directory, otherwise it returns false ."],
                    ["boolean fs:dirSize(String path)", "It returns the size in bytes of all the files in the specified path."],
                    ["boolean fs:fileSize(String path)", "It returns the size in bytes of specified file."],
                    ["boolean fs:blockSize(String path)", "It returns the block size in bytes of specified file."]
                  ];
                    