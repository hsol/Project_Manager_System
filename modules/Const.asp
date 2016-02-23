<%@CODEPAGE="65001" LANGUAGE="VBSCRIPT"%>
<!-- #include file="aspJSON1.17.asp" -->
<%
	Response.charset = "utf-8"
	Response.codepage="65001"
	Response.ContentType="text/html;charset=utf-8"	
	Response.Expires = -1
	Response.AddHeader "Pragma","no-cache"
	Response.AddHeader "cache-control","no-store"
	Response.buffer=True
	Session.Codepage="65001"
	Session.Timeout=60

	Set mainDB = New aspJSON
	mainDB.data.add "ip", "localhost\DB"
	mainDB.data.add "id", "sa"
	mainDB.data.add "pw", "cntt2015!!"
	mainDB.data.add "name", "CNTPMS"

	Set intraDB = New aspJSON
	intraDB.data.add "ip", "211.219.135.29"
	intraDB.data.add "id", "sa"
	intraDB.data.add "pw", "cntt"
	intraDB.data.add "name", "INTRANET"

	Set userClass = New aspJSON
	userClass.data.add "admin", "9"
	userClass.data.add "user", "1"

	Set User = New aspJSON
	If Session("userInfo") = "" Then
		User.data.add "isLogin", "false"
		User.data.add "userId", ""
		User.data.add "userName", "Guest"
		User.data.add "userClass", ""
		User.data.add "userPart", ""
		User.data.add "userIp", Request.ServerVariables("REMOTE_ADDR")
		Session("userInfo") = User.JSONoutput()
		Response.Redirect(getPath())
	Else
		User.loadJSON(Session("userInfo"))
	End If
	
	Set DBHelper = new clsDBHelper
	Set res = New aspJSON
	res.data.add "state", ""
	res.data.add "code", ""
	res.data.add "message", ""
%>