<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html  xmlns="http://www.w3.org/1999/xhtml" style="overflow: hidden;">
<head>
<%@ include file="../common/meta.jsp"%>
<%@ include file="../common/header.jsp"%>
</head>
<script type="text/javascript">
$(document).ready(function() {
	$(window).resize(function() {
	    $('#mainFrame').height($(window).height() - 60);
	});
	$(window).trigger('resize');
});
</script>
<body>
<div id="topMenu" style="height:50px">
	<div>
		<div style='float:left;margin-right:20px' class="top_menu" onclick="document.location.href='/workflow/workflow.do';">Application Designer</div>
		<div style='float:left' class="top_menu_selected" onclick="document.location.href='/workflow/jobstatus.do';">Job Management</div>
		<div style='float:right' class="ui-widget"><a href="http://github.com/gruter/cloumon-oozie" target="_blank">cloumon-oozie designer 0.9</a></div>
		<div style='clear:both'></div>
	</div>	
</div>
<div id="mainFrame">
	<iframe scrolling="no" style="width:100%; height:100%; overflow: hidden; border:0" src="/workflow/jobstatusFrame.do"></iframe>
</div>
</body>
</html>