<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../common/taglibs.jsp"%>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" /> 
<title>Cloumon Enterprise</title>
<link rel="shortcut icon" type="image/x-icon" href="<c:url value='/resources/images/icons/favicon.ico'/>" />
<!-- Ext -->
<style type="text/css">
.cluster-down, .x-grid-tree-node-expanded .cluster-down{
	background-image: url(${ctx}/resources/images/icons/fam/red-led.gif);	
}

.cluster-running, .x-grid-tree-node-expanded .cluster-running{
	background-repeat: no-repeat;
	background-image: url(${ctx}/resources/images/icons/fam/green-led.gif);
}
.cluster-error, .x-grid-tree-node-expanded .cluster-error{
	background-repeat: no-repeat;
	background-image: url(${ctx}/resources/images/icons/fam/red-led.gif);
}
.hadoop-namenode, .x-grid-tree-node-expanded {
	background-repeat: no-repeat;
	background-image: url(${ctx}/resources/images/icons/fam/accept.gif);
}

.databaseicon, .x-grid-tree-node-expanded .databaseicon{
	background-repeat: no-repeat;
    background-image: url(${ctx}/resources/images/icons/fam/database.png);
}

.tableicon, .x-grid-tree-node-expanded .tableicon{
	background-repeat: no-repeat;
    background-image: url(${ctx}/resources/images/icons/fam/table.png);
}

.connect, .x-grid-tree-node-expanded .connect {
	background-repeat: no-repeat;
    background-image: url(${ctx}/resources/images/icons/fam/connect.gif);
}

p {
	margin: 5px;
}
.settings {
	background-repeat: no-repeat;	
	background-image: url(${ctx}/resources/images/icons/fam/folder_wrench.png);
}
.nav {
	background-repeat: no-repeat;
	background-image: url(${ctx}/resources/images/icons/fam/folder_go.png);
}
.info {
	background-repeat: no-repeat;
	background-image: url(${ctx}/resources/images/icons/fam/information.png);
}

.logo {
	height: 28px !important;
	width: 110px !important;
	background-repeat: no-repeat;
	background-image: url(${ctx}/resources/images/cloumon.png);
}

.menu-zookeeper {
	height: 32px !important;
	width: 125px !important;
	background-repeat: no-repeat;
	background-image: url(${ctx}/resources/images/zookeeper_logo.png);
}

.menu-cassandra {
	height: 32px !important;
	width: 137px !important;
	background-repeat: no-repeat;
	background-image: url(${ctx}/resources/images/cassandra_logo.png);
}

.menu-hadoop {
	height: 32px !important;
	width: 110px !important;
	background-repeat: no-repeat;
	background-image: url(${ctx}/resources/images/hadoop_logo.png);
}
.menu-hbase {
	height: 32px !important;
	width: 97px !important;
	background-repeat: no-repeat;
	background-image: url(${ctx}/resources/images/hbase_logo.png);
}

.menu-flume {
	height: 32px !important;
	width: 99px !important;
	background-repeat: no-repeat;
	background-image: url(${ctx}/resources/images/flume_logo.png);
}

.menu-hive {
	height: 32px !important;
	width: 84px !important;
	background-repeat: no-repeat;
	background-image: url(${ctx}/resources/images/hive_logo.png);
}

.menu-oozie {
	height: 32px !important;
	width: 84px !important;
	background-repeat: no-repeat;
	background-image: url(${ctx}/resources/images/oozie_logo.png);
}

.msg .x-box-mc {
    font-size:14px;
}
#msg-div {
    position:absolute;
    left:65%;
    top:10px;
    width:300px;
    z-index:20000;
}
#msg-div .msg {
    border-radius: 8px;
    -moz-border-radius: 8px;
    background: #F6F6F6;
    border: 2px solid #ccc;
    margin-top: 2px;
    padding: 10px 15px;
    color: #555;
}
#msg-div .msg h3 {
    margin: 0 0 8px;
    font-weight: bold;
    font-size: 15px;
}
#msg-div .msg p {
    margin: 0;
}
.settings {
    background-image: url(${ctx}/resources/images/icons/fam/gears.gif) !important;
}
.add {
    background-image: url(${ctx}/resources/images/icons/fam/add.gif) !important;
}
.accept {
    background-image: url(${ctx}/resources/images/icons/fam/accept.gif) !important;
}
.information {
    background-image: url(${ctx}/resources/images/icons/fam/information.png) !important;
}
.option {
    background-image: url(${ctx}/resources/images/icons/fam/plugin.gif) !important;
}
.remove {
    background-image: url(${ctx}/resources/images/icons/fam/delete.gif) !important;
}
.delete {
    background-image: url(${ctx}/resources/images/icons/fam/delete2.gif) !important;
}
.save {
    background-image: url(${ctx}/resources/images/icons/fam/save.gif) !important;
}
.saved {
    background-image: url(${ctx}/resources/extjs/ux/statusbar/images/saved.png) !important;
}
.reset {
    background-image: url(${ctx}/resources/images/icons/fam/stop.png) !important;
}
.rellback {
    background-image: url(${ctx}/resources/images/icons/fam/rollback.gif) !important;
}
.serverconfig {
    background-image: url(${ctx}/resources/images/icons/fam/configs.png) !important;
}
.treeicon {
    background-image: url(${ctx}/resources/images/icons/fam/list-items.gif) !important;
}
.dashboardicon {
    background-image: url(${ctx}/resources/images/icons/fam/album.gif) !important;
}

.logout {
    background-image: url(${ctx}/resources/images/icons/logout.gif) !important;
}

.barchart {
    background-image: url(${ctx}/resources/images/icons/fam/chart48x48.png) !important;
}

.green-led {
    background-image: url(${ctx}/resources/images/icons/fam/green-led.gif) !important;
}

.red-led {
    background-image: url(${ctx}/resources/images/icons/fam/red-led.gif) !important;
}

.download {
    background-image: url(${ctx}/resources/images/icons/fam/download.gif) !important;
}
.execute {
    background-image: url("${ctx}/resources/extjs/resources/themes/images/default/shared/right-btn.gif");
}

.x-grid-checkheader {
    height: 14px;
    background-image: url('${ctx}/resources/extjs/resources/themes/images/default/grid/unchecked.gif');
    background-position: 50% -2px;
    background-repeat: no-repeat;
    background-color: transparent;
}

.x-grid-checkheader-checked {
    background-image: url('${ctx}/resources/extjs/resources/themes/images/default/grid/checked.gif');
}

.x-grid-checkheader-editor .x-form-cb-wrap {
    text-align: center;
}

/* style rows on mouseover */
.x-grid-row-over .x-grid-cell-inner {
    font-weight: bold;
}
/* shared styles for the ActionColumn icons */
.x-action-col-cell img {
    height: 16px;
    width: 16px;
    margin-left:4px;
    cursor: pointer;
}
/* custom icon for the  ActionColumn icon */
.x-action-col-cell img.delete {
    background-image: url(${ctx}/resources/images/icons/fam/delete.gif);
}
.x-action-col-cell img.rollback {
    background-image: url(${ctx}/resources/images/icons/fam/rollback.gif);
}
.red-node {
	color: red;
}

.red-icon {
	background-color: red;
}


.x-grid-row ,.x-grid-cell, .x-unselectable, .x-unselectable * {
 -webkit-user-select: text !important;
 -o-user-select: text !important;
 -khtml-user-select: all !important;
 -ms-user-select: text !important;
 user-select: text !important;
 -moz-user-select: text !important;
}

.titleBG .x-toolbar-default {
 background: none !important;
}

/* StatusBar - structure */
.x-statusbar .x-status-text {
    cursor: default;
/*
    height: 21px;
    line-height: 21px;
    padding: 0 4px;
*/
}
.x-statusbar .x-status-busy {
    padding-left: 25px !important;
    background: transparent no-repeat 3px 0;
}

.x-toolbar div.xtb-text

.x-statusbar .x-status-text-panel {
    border-top: 1px solid;
    border-right: 1px solid;
    border-bottom: 1px solid;
    border-left: 1px solid;
    padding: 2px 8px 2px 5px;
}

/* StatusBar word processor example styles */

#word-status .x-status-text-panel .spacer {
    width: 60px;
    font-size:0;
    line-height:0;
}
#word-status .x-status-busy {
    padding-left: 25px !important;
    background: transparent no-repeat 3px 0;
}
#word-status .x-status-saved {
    padding-left: 25px !important;
    background: transparent no-repeat 3px 0;
}

/* StatusBar form validation example styles */

.x-statusbar .x-status-error {
    cursor: pointer;
    padding-left: 25px !important;
    background: transparent no-repeat 3px 0;
}
.x-statusbar .x-status-valid {
    padding-left: 25px !important;
    background: transparent no-repeat 3px 0;
}
.x-status-error-list {
    font: 11px tahoma,arial,verdana,sans-serif;
    position: absolute;
    z-index: 9999;
    border-top: 1px solid;
    border-right: 1px solid;
    border-bottom: 1px solid;
    border-left: 1px solid;
    padding: 5px 10px;
}
.x-status-error-list li {
    cursor: pointer;
    list-style: disc;
    margin-left: 10px;
}
.x-status-error-list li a {
    text-decoration: none;
}
.x-status-error-list li a:hover {
    text-decoration: underline;
}


/* *********************************************************** */
/* *********************************************************** */
/* *********************************************************** */


/* StatusBar - visual */

.x-statusbar .x-status-busy {
    background-image: url(${ctx}/resources/extjs/ux/statusbar/images/loading.gif);
}
.x-statusbar .x-status-text-panel {
    border-color: #99bbe8 #fff #fff #99bbe8;
}

/* StatusBar word processor example styles */

#word-status .x-status-text {
    color: #777;
}
#word-status .x-status-busy {
    background-image: url(${ctx}/resources/extjs/ux/statusbar/images/saving.gif);
}
#word-status .x-status-saved {
    background-image: url(${ctx}/resources/extjs/ux/statusbar/images/saved.png);
}

/* StatusBar form validation example styles */

.x-statusbar .x-status-error {
    color: #C33;
    background-image: url(${ctx}/resources/extjs/ux/statusbar/images/exclamation.gif);
}
.x-statusbar .x-status-valid {
    background-image: url(${ctx}/resources/extjs/ux/statusbar/images/accept.png);
}
.x-status-error-list {
    border-color: #C33;
    background: white;
}
.x-status-error-list li a {
    color: #15428B;
}
</style>
<script type="text/javascript" src="<c:url value='/resources/extjs/ext-all.js'/>"></script>
<script type="text/javascript" src="<c:url value='/resources/extjs/ux/statusbar/StatusBar.js'/>"></script>
<script type="text/javascript" src="<c:url value='/resources/extjs/ux/LiveSearchGridPanel.js'/>"></script>
<script type="text/javascript">
CLOUMON_APPLICATION_CONTEXT = '${ctx}';
if(CLOUMON_APPLICATION_CONTEXT != '/') CLOUMON_APPLICATION_CONTEXT += '/';

Ext.override(Ext.tree.View,{
	listeners: {
		'afteritemexpand': function(node) {
			this.getSelectionModel().select(node);
		}
	}
});

Ext.form.FieldSet.override({
	padding : 10
});

Ext.override(Ext.view.AbstractView, {
	onRender: function() {
        var me = this;
        me.callOverridden(arguments);
        if (me.loadMask && Ext.isObject(me.store)) {
            me.setMaskBind(me.store);
        }
    }
});
Ext.util.Format.fileSize = function(size, threshold, decimal) {
        threshold= threshold? threshold: 0.95;//set default to a Windows style of FileSizes
        threshold= Math.min(Math.max(threshold, 0.75), 1); //should be between 75-100%
        decimal= decimal? decimal: 2;//set default to 2 decimal units
        decimal= Math.min(Math.max(decimal, 0), 4); //should be between 0-4
        if (size < 1024*threshold) { //pow(2,10)
            return (Math.round(((size*Math.pow(10,decimal))))/Math.pow(10,decimal)) + " Bytes";
        } else if (size < Math.pow(1024, 2)*threshold) { //pow(2,20)
            return (Math.round(((size*Math.pow(10,decimal)) / 1024))/Math.pow(10,decimal)) + " KB";
        } else if (size < Math.pow(1024, 3)*threshold) { //pow(2,30)
            return (Math.round(((size*Math.pow(10,decimal)) / Math.pow(1024, 2)))/Math.pow(10,decimal)) + " MB";
        } else if (size < Math.pow(1024, 4)*threshold) { //pow(2,40)
            return (Math.round(((size*Math.pow(10,decimal)) / Math.pow(1024, 3)))/Math.pow(10,decimal)) + " GB";
        } else if (size < Math.pow(1024, 5)*threshold) { //pow(2,50)
            return (Math.round(((size*Math.pow(10,decimal)) / Math.pow(1024, 4)))/Math.pow(10,decimal)) + " TB";
        } else if (size < Math.pow(1024, 6)*threshold){ //pow(2,60)
            return (Math.round(((size*Math.pow(10,decimal)) / Math.pow(1024, 5)))/Math.pow(10,decimal)) + " PB";
        } else {
        	return 'N/A';
        }
};

var clock = Ext.create('Ext.toolbar.TextItem', {text: Ext.Date.format(new Date(), 'g:i:s A')});

Ext.Ajax.on('requestcomplete', function(conn, response, options){
		try{
			var responseJson = Ext.decode(response.responseText);
			if(responseJson.success === false && responseJson.msg != "") {
	  			alert("ERROR: " + responseJson.msg);
			}
		} catch(e) {
		}
	//console.log('arguments: %o', arguments);
	});

Ext.Ajax.on('requestexception', function(conn, response, options){
	//console.log('exception arguments: %o', arguments);
		if(response.status == 403){
			delete options.failure;
			delete options.callback;
			try{
				var responseJson = Ext.decode(response.responseText);
	      		if (responseJson.success === false && responseJson.url) { 
	      			window.location = responseJson.url;
	      		}
			}catch(e){
				//console.error(e);
				window.location = CLOUMON_APPLICATION_CONTEXT;
			}
		}else if(response.status == 404){
			delete options.failure;
			delete options.callback;
			alert(response.responseText);
		}else if(response.status == 200){
			try{
				var responseJson = Ext.decode(response.responseText);
	      		if (responseJson.success === false && responseJson.status === 302) {
	      			delete options.failure;
	    			delete options.callback;
	      			alert(responseJson.msg);
	      		} else if(responseJson.success === false) {
		      		alert("ERROR: " + responseJson.msg);
	      		}
			}catch(e){
			}
		}
	});
/*-------------------------------------------------  */

/* -----------------Validator------------------------------- */
  Ext.apply(Ext.form.field.VTypes, {
	    IPAddress:  function(v) {
	        return /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.test(v);
	    },
	    IPAddressText: 'Must be a numeric IP address',
	    IPAddressMask: /[\d\.]/i
	});
  Ext.apply(Ext.form.field.VTypes, {
	    Port:  function(v) {
	        return /^[\d]+$/i.test(v);
	    },
	    PortText: 'Must be a numeric Port',
	    PortMask: /[\d]+/i
	});
 
 /* -------------------------------------------------------  */
Ext.define('Cloumon', {
	singleton: true,
	onSuccessOrFailForm : function(form, action) {
		// form callback
	    var result = action.result;
	    if (result && result.success) {
	      	Ext.MessageBox.alert('Success',action.result.msg);
	    }
	    else {
	    	switch (action.failureType) {
	            case Ext.form.action.Action.CLIENT_INVALID:
	                Ext.Msg.alert('Failure', 'Form fields may not be submitted with invalid values');
	                break;
	            case Ext.form.action.Action.CONNECT_FAILURE:
	                Ext.Msg.alert('Failure', 'Ajax communication failed');
	                break;
	            case Ext.form.action.Action.SERVER_INVALID:
	               Ext.Msg.alert('Failure', action.result.msg);
	       }
	    }
	  },
	onFailureAjax: function(response) {
		//ajax request failure callback
     		var responseJson = Ext.decode(response.responseText);
     		Ext.Msg.alert('failure', responseJson.msg);
  	},
  	exceptionListener: function(proxy, response, op, args) {
  		//proxy exception listener
    	if(op.action == 'read'){
			Ext.Msg.alert('Error', proxy.reader.jsonData.msg);
        }
    },
    storeCallback: function(records, operation, success) {
        //the operation object contains all of the details of the load operation
        if(!success)
        	Ext.Msg.alert('Error', proxy.reader.jsonData.msg);
    	 	//console.log('load failed -- arguments: %o', arguments);
    },
    msgCt : null,

    createBox : function(t, s){
       return '<div class="msg"><h3>' + t + '</h3><p>' + s + '</p></div>';
    },
    msg : function(title, format){
    		if(!title) title = '';
    		if(!format) format = '';
    		
            if(!this.msgCt){
               this.msgCt = Ext.core.DomHelper.insertFirst(document.body, {id:'msg-div'}, true);
            }
            var s = Ext.String.format.apply(String, Array.prototype.slice.call(arguments, 1));
            var m = Ext.core.DomHelper.append(this.msgCt, this.createBox(title, s), true);
            m.hide();
            m.slideIn('t').ghost("t", { delay: 1000, remove: true});
     }

});
 
if(typeof Ext != 'undefined'){
	  Ext.core.Element.prototype.unselectable = function(){return this;};
	  Ext.view.TableChunker.metaRowTpl = [
	   '<tr class="' + Ext.baseCSSPrefix + 'grid-row {addlSelector} {[this.embedRowCls()]}" {[this.embedRowAttr()]}>',
	    '<tpl for="columns">',
	     '<td class="{cls} ' + Ext.baseCSSPrefix + 'grid-cell ' + Ext.baseCSSPrefix + 'grid-cell-{columnId} {{id}-modified} {{id}-tdCls} {[this.firstOrLastCls(xindex, xcount)]}" {{id}-tdAttr}><div class="' + Ext.baseCSSPrefix + 'grid-cell-inner ' + Ext.baseCSSPrefix + 'unselectable" style="{{id}-style}; text-align: {align};">{{id}}</div></td>',
	    '</tpl>',
	   '</tr>'
	  ];
}

	
getTopMenuItems = function(){
	return  [{
				xtype: 'tbtext',
				padding: '3 5',
				rowspan: 3,
		    	cls: 'logo',
		    	style: {
		    		 cursor: 'pointer'
		        },
		    	listeners: {
		            click: {
		                element: 'el', //bind to the underlying el property on the panel
		                fn: function(){ window.location.href = Ext.urlAppend(CLOUMON_APPLICATION_CONTEXT + 'common/main.do'); }
		            }
		        }
			},'-',{
				scale: Ext.isIE ? '' : 'large',
                rowspan: 3,
                arrowAlign:'right',
				cls: 'menu-hadoop',
				menu:[{
		    		text : 'File System',
		    		iconCls : 'serverconfig',
		    		url : CLOUMON_APPLICATION_CONTEXT+'hadoop/cluster.do',
		    		handler: function(){
		               window.location.href = Ext.urlAppend(this.url, 'menu=cluster');
		            }
		    	}, {
		    		text : 'File Browser',
		    		iconCls : 'dashboardicon',
		    		url : CLOUMON_APPLICATION_CONTEXT+'hadoop/file.do',
		    		handler: function(){
		               window.location.href = Ext.urlAppend(this.url, 'menu=file');
		            }
		    	}, {
		    		text : 'M/R Cluster',
		    		iconCls : 'serverconfig',
		    		url : CLOUMON_APPLICATION_CONTEXT+'hadoopmr/mrcluster.do',
		    		handler: function(){
		               window.location.href = Ext.urlAppend(this.url, 'menu=mrcluster');
		            }
		    	}, {
		    		text : 'Job Management',
		    		iconCls : 'treeicon',
		    		url : CLOUMON_APPLICATION_CONTEXT+'hadoopmr/mrjob.do',
		    		handler: function(){
		               window.location.href = Ext.urlAppend(this.url, 'menu=mrjob');
		            }
		    	}, {
		    		text : 'Job Scheduling',
		    		iconCls : 'treeicon',
		    		url : CLOUMON_APPLICATION_CONTEXT+'scheduler/scheduler.do',
		    		handler: function(){
		               window.location.href = Ext.urlAppend(this.url, 'menu=scheduler');
		            }
		    	}]
			},'-',{
				scale: Ext.isIE ? '' : 'large',
                rowspan: 3,
                iconAlign: 'top',
                arrowAlign:'right',
				cls: 'menu-hive',
				menu:[{
		    		text : 'Query',
		    		iconCls : 'serverconfig',
		    		url : CLOUMON_APPLICATION_CONTEXT+'hive/query/main.do',
		    		handler: function(){
		               window.location.href = Ext.urlAppend(this.url, 'menu=query');
		            }
				},{
					text: 'Schema',
					iconCls : 'treeicon',
					url : CLOUMON_APPLICATION_CONTEXT+'hive/meta/main.do',
					handler: function(){
		               window.location.href = Ext.urlAppend(this.url, 'menu=meta');
		            }
		    	}]
			},'-',{
				scale: Ext.isIE ? '' : 'large',
                rowspan: 3,
                iconAlign: 'top',
                arrowAlign:'right',
				cls: 'menu-oozie',
				menu:[{
		    		text : 'App Design',
		    		iconCls : 'serverconfig',
		    		url : CLOUMON_APPLICATION_CONTEXT+'workflow/workflow.do',
		    		handler: function(){
		               window.location.href = Ext.urlAppend(this.url, 'menu=query');
		            }
				},{
					text: 'Job Management',
					iconCls : 'treeicon',
					url : CLOUMON_APPLICATION_CONTEXT+'workflow/jobstatus.do',
					handler: function(){
		               window.location.href = Ext.urlAppend(this.url, 'menu=meta');
		            }
		    	}]
			},'-',{
				scale: Ext.isIE ? '' : 'large',
                rowspan: 3,
                arrowAlign:'right',
				cls: 'menu-flume',
				menu:[{
		    		text : 'Cluster',
		    		iconCls : 'serverconfig',
		    		url : CLOUMON_APPLICATION_CONTEXT+'flume/cluster.do',
		    		handler: function(){
		               window.location.href = Ext.urlAppend(this.url, 'menu=cluster');
		            }
		    	}]
			},'-',{
				scale: Ext.isIE ? '' : 'large',
                rowspan: 3,
                iconAlign: 'top',
                arrowAlign:'right',
				cls: 'menu-zookeeper',
	    		menu:[{
					text : 'Dashboard',
					iconCls : 'dashboardicon',
					url : CLOUMON_APPLICATION_CONTEXT+'zookeeper/dashboard.do',
					handler: function(){
			               window.location.href = Ext.urlAppend(this.url, 'menu=dashboard');
		            }
				},{
		    		text : 'Cluster',
		    		iconCls : 'serverconfig',
		    		url : CLOUMON_APPLICATION_CONTEXT+'zookeeper/cluster.do',
		    		handler: function(){
			               window.location.href = Ext.urlAppend(this.url, 'menu=cluster');
		            }
		    	},{
		    		text : 'ZNode',
		    		iconCls : 'treeicon',
		    		url : CLOUMON_APPLICATION_CONTEXT+'zookeeper/znode.do',
		    		handler: function(){
			               window.location.href = Ext.urlAppend(this.url, 'menu=znode');
		            }
		    	}]
			}, '-',{
				scale: Ext.isIE ? '' : 'large',
                rowspan: 3,
                arrowAlign:'right',
				cls: 'menu-hbase',
				menu:[{
		    		text : 'Cluster',
		    		iconCls : 'serverconfig',
		    		url : CLOUMON_APPLICATION_CONTEXT+'hbase/cluster.do',
		    		handler: function(){
		               window.location.href = Ext.urlAppend(this.url, 'menu=cluster');
		            }
		    	}]
			}, '-',{
				scale: Ext.isIE ? '' : 'large',
                rowspan: 3,
                iconAlign: 'top',
                arrowAlign:'right',
				cls: 'menu-cassandra',
				menu:[{
		    		text : 'Cluster',
		    		iconCls : 'serverconfig',
		    		url : CLOUMON_APPLICATION_CONTEXT+'cassandra/cluster.do',
		    		handler: function(){
		               window.location.href = Ext.urlAppend(this.url, 'menu=cluster');
		            }
				},{
					text: 'Data',
					iconCls : 'treeicon',
					url : CLOUMON_APPLICATION_CONTEXT+'cassandra/crud.do',
					handler: function(){
		               window.location.href = Ext.urlAppend(this.url, 'menu=cluster');
		            }
		    	}]
			},'->', {
				disabled:	true,
				text: '<%= String.format("%6.2f/%6.2fMB",(double) (Runtime.getRuntime().totalMemory() -Runtime.getRuntime().freeMemory()) / (1024 * 1024), (double) Runtime.getRuntime().totalMemory() / (1024 * 1024)) %>'
			}, {
				text: 'Setting',
				url : CLOUMON_APPLICATION_CONTEXT + 'conf/conf.do',
				iconCls: 'settings',
				hrefTarget : '_self'
			},{
				text: 'LogOut',
				iconCls: 'logout',
				url : CLOUMON_APPLICATION_CONTEXT+'logout',
				hrefTarget: '_self'
			}
		];
};

createClusterTreeCmp = function(cmp_id){
    return {
    	xtype: 'treepanel',
        id: cmp_id,
        rootVisible: false,
        autoScroll: true,
        border: false,
        store: Ext.create('Ext.data.TreeStore', {
            proxy: {
                type: 'ajax',
                url: CLOUMON_APPLICATION_CONTEXT+'zookeeper/cluster/tree.do'
            },
            sorters: [{
                property: 'text',
                direction: 'ASC'
            }],
            fields : [ {name:'text', type:'string'}, 
			           {name:'value', type:'string'},
			           {name:'category', type:'string'},
			           {name:'running', type:'boolean'}
			]
        }),
        listeners: {
			'itemcollapse': function(node) {
				node.set('loaded', false); //clear node data cache
			}
		},
		dockedItems: [{
    	    xtype: 'toolbar',
    	    dock: 'top',
    	    items: [{
            	text   : 'Add',
            	iconCls : 'add',
                handler: function() {
	            	var selNode = getSelectedTreeNode('cluster-tree-cmp');
	            	if(!selNode) return;
	            	if(selNode.get('category') == 'root'){
                		showCreateClusterWindow('cluster-tree-create-window');
	            	}else if(selNode.get('category') == 'cluster'){
	            		showCreateServerWindow('server-tree-create-window');
	            	}
                }
            },'-',
            {
                  text   : 'Delete',
                  iconCls: 'remove',
                  handler: function() {
                	var selNode = getSelectedTreeNode('cluster-tree-cmp');
  	            	if(!selNode) return;
  	            	if(selNode.get('category') == 'cluster'){
  	            		submitDeleteClusterTreeNode(selNode);
  	            	}else if(selNode.get('category') == 'server'){
  	            		submitDeleteServerTreeNode(selNode);
  	            	}
                  }
              }]
    	}]
    }; 
};



createClusterWindowCmp = function(cmp_id){ 
	return Ext.create('Ext.form.Panel', {
		frame: true,
        bodyPadding: 5,
        border :false,
        waitMsgTarget: true,
        id: cmp_id, 
        defaultType: 'textfield',
        fieldDefaults: {
            labelAlign: 'left',
            labelWidth: 100,
            anchor: '100%'
        },
        items: [{
		            flex: 1,
		            name: 'cluster',
		            fieldLabel: 'Cluster Name',
		            allowBlank: false,
		            labelWidth: 100
		        }, {
		            flex: 1,
		            name: 'description',
		            fieldLabel: 'Description',
		            allowBlank: false,
		            labelWidth: 100
		            
		        }],
		        buttons: [{
		            text: 'Close',
		            handler: function() {
		            	this.up('window').destroy();
		            }
		        },{
		            text: 'Add',
		            disabled: true,
		            formBind: true, //only enabled once the form is valid
		            handler: function(){
		            	var selNode = getSelectedTreeNode('cluster-tree-cmp');
		            	
		            	if (!this.up('form').getForm().isValid()){
		            		return;
		            	}
		            	submitAddClusterTreeNode(this.up('form'), selNode);
		            }
		        }]
    });
};

createServerWindowCmp = function(cmp_id){ 
	return Ext.create('Ext.form.Panel', {
		frame: true,
        bodyPadding: 5,
        border :false,
        waitMsgTarget: true,
        id: cmp_id, 
        defaultType: 'textfield',
        fieldDefaults: {
            labelAlign: 'left',
            labelWidth: 100,
            anchor: '100%'
        },
        items: [{
            xtype: 'fieldset',
            labelStyle: 'font-weight:bold;padding:0',
            layout: 'hbox',
            labelAlign: 'top',
            defaultType: 'textfield',
            fieldDefaults: {
                labelAlign: 'left'
            },
            items: [{
			            flex: 2,
			            name: 'host',
			            fieldLabel: 'Host Name',
			            allowBlank: false,
			            margin: '0 10 0 0',
			            labelWidth: 70
			        }, {
			            flex: 1,
			            name: 'port',
			            vtype: 'Port',
			            fieldLabel: 'Port',
			            allowBlank: false,
			            margin: '0 10 0 0',
			            labelWidth: 40
			            
			        }, {
			            xtype:          'combo',
			            labelWidth: 40,
			            maxWidth : 100,
			            flex: 1,
			            mode:           'local',
			            value:          'Y',
			            triggerAction:  'all',
			            forceSelection: true,
			            editable:       false,
			            fieldLabel:     'Alarm',
			            name:           'alarm',
			            displayField:   'name',
			            valueField:     'value',
			            queryMode: 'local',
			            store:          Ext.create('Ext.data.Store', {
			                fields : ['name', 'value'],
			                data   : [
			                    {name : 'YES',   value: 'N'},
			                    {name : 'NO',  value: 'Y'}
			                ]
			            })
			        }]
		        }],
		        buttons: [{
		            text: 'Close',
		            handler: function() {
		            	this.up('window').destroy();
		            }
		        },{
		            text: 'Add',
		            disabled: true,
		            formBind: true, //only enabled once the form is valid
		            handler: function(){
		            	var selNode = getSelectedTreeNode('cluster-tree-cmp');
		            	
		            	if (!this.up('form').getForm().isValid()){
		            		return;
		            	}
		            	
		            	var serverJson = this.up('form').getForm().getFieldValues();
		            	var formPanel = this.up('form');
		            	var confirm =Ext.MessageBox.confirm(
		              			'Are you sure?', 
		            			'Please confirm the creation of ' + serverJson['host'],
		            			function(btn){
		              					if (btn != 'yes') return;

		              					formPanel.getForm().submit({
		                        	    clientValidation: true,
		                        	    url: CLOUMON_APPLICATION_CONTEXT+'zookeeper/cluster/createserver.do',
		                        	    params: {
					            	        cluster: selNode.get('value')
					            	    },
		                        	    success: function(form, action) {
		                        	    	formPanel.up('window').destroy();
		                        	    	
		                        	    	selNode.set('expanded', false); //clear node data cache
                                            selNode.set('loaded', false); //clear node data cache
                                            while(selNode.firstChild) {
                                                      selNode.removeChild(selNode.firstChild);
                                            }
		                    				selNode.expand();
		                        	    	Cloumon.msg(action.result.msg, '');
		                        	    },
		                        	    failure: function(form, action) {
		                        	    	Cloumon.onSuccessOrFailForm(form, action);
		                        	        formPanel.up('window').destroy();
		                        	    }
		                        	});
		              			  
		            		  });
		            }
		        }]
    });
};

submitAddClusterTreeNode = function(formPanel, selNode){
	var clusterJson = formPanel.getForm().getFieldValues();
	var confirm =Ext.MessageBox.confirm(
  			'Are you sure?', 
			'Please confirm the creation of ' + clusterJson['cluster'],
			function(btn){
  					if (btn != 'yes') return;

  					formPanel.getForm().submit({
            	    clientValidation: true,
            	    url: CLOUMON_APPLICATION_CONTEXT+'zookeeper/cluster/createcluster.do',
            	    success: function(form, action) {
            	    	formPanel.up('window').destroy();
            	    	
            	    	selNode.appendChild(action.result.data,undefined, true);
            	    	selNode.expand();
            	    	Cloumon.msg(action.result.msg, '');
            	    },
            	    failure: function(form, action) {
            	    	Cloumon.onSuccessOrFailForm(form, action);
            	        formPanel.up('window').destroy();
            	    }
            	});
  			  
		  });
};

submitDeleteClusterTreeNode = function(selNode){
	var confirm =Ext.MessageBox.confirm(
  			'Are you sure?', 
			'Please confirm the deletion of ' + selNode.get('value'),
			function(btn){
  					if (btn != 'yes') return;
					
  					Ext.Ajax.request({
  				      	url: CLOUMON_APPLICATION_CONTEXT+'zookeeper/cluster/deletecluster.do',
  				      	params : {
  				      		cluster : selNode.get('value')
  				      	},
  				      	success: function(response, opts) { 
  				      		var responseJson = Ext.decode(response.responseText);
  				      		if (responseJson.success === true) { 
  				      			var treePanel = Ext.getCmp('cluster-tree-cmp'); 
  				       			treePanel.getSelectionModel().deselect(selNode);
  				       			selNode.remove();
  				       			Cloumon.msg(responseJson.msg, '');
  				      		} else {
  				      			Ext.Msg.alert('failure', responseJson.msg);
  				      		}
  				      	},
  				      	failure: Cloumon.onFailureAjax
		      	});
  			  
		  });
};

submitDeleteServerTreeNode = function(selNode){
	var confirm =Ext.MessageBox.confirm(
  			'Are you sure?', 
			'Please confirm the deletion of ' + selNode.get('value'),
			function(btn){
  					if (btn != 'yes') return;
					
  					Ext.Ajax.request({
  				      	url: CLOUMON_APPLICATION_CONTEXT+'zookeeper/cluster/deleteserver.do',
  				      	params : {
  				      		cluster : selNode.parentNode.get('value'),
  				      		server : selNode.get('value')
  				      	},
  				      	success: function(response, opts) { 
  				      		var responseJson = Ext.decode(response.responseText);
  				      		if (responseJson.success === true) { 
  				      			var treePanel = Ext.getCmp('cluster-tree-cmp'); 
  				       			treePanel.getSelectionModel().deselect(selNode);
  				       			selNode.remove();
  				       			Cloumon.msg(responseJson.msg, '');
  				      		} else {
  				      			Ext.Msg.alert('failure', responseJson.msg);
  				      		}
  				      	},
  				      	failure: Cloumon.onFailureAjax
		      	});
  			  
		  });
};



showCreateClusterWindow = function(cmp_id){
	var win = Ext.getCmp(cmp_id);
	if(!win){
		var win = Ext.widget('window', {
            title: 'Create Cluster',
			id: cmp_id,
            width: 500,
            layout: 'fit',
            resizable: true,
            modal: true,
            items: createClusterWindowCmp('cluster-tree-create-form')
        });
	}
	win.show();
};

showCreateServerWindow = function(cmp_id){
	var win = Ext.getCmp(cmp_id);
	if(!win){
		var win = Ext.widget('window', {
            title: 'Create Server',
			id: cmp_id,
            width: 600,
            layout: 'fit',
            resizable: true,
            modal: true,
            items: createServerWindowCmp('server-tree-create-form')
        });
	}
	win.show();
};

getSelectedTreeNode = function(cmp_id){
	var cmp = Ext.getCmp(cmp_id);
	if(cmp) return Ext.getCmp(cmp_id).getSelectionModel().getLastSelected();
	return null;
};

renderTreeChildren = function(tree, parentNode, requestUrl, requestParams){
	Ext.Ajax.request({
      	url: requestUrl,
      	method: 'GET',
      	params : requestParams,
      	success: function(response, opts) {
      		 
      		var responseJson = Ext.decode(response.responseText);
      		if (responseJson.success === true) { 
      			tree.suspendLayout = true;
      			if(responseJson.data.length > 0){
      				
      				parentNode.removeAll();
	      			for(var i=0; i < responseJson.data.length; i++){
	      				parentNode.appendChild(responseJson.data[i],undefined, true);
	      				parentNode.set('leaf', false);
	      			}
      			}else{
      				parentNode.set('leaf', true);
      			}
      			tree.suspendLayout = false;
      		} else {
      			Ext.Msg.alert('failure', responseJson.msg);
      		} 
      		tree.el.unmask();
      	}
	});
};
    
</script>