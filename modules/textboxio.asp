<!-- #include virtual="/modules/Common.asp"  -->
<%
	Set uploadForm = Server.CreateObject ("SiteGalaxyUpload.Form")
	Set fso = Server.CreateObject("Scripting.FileSystemObject")
	parentTable = "textboxio"
	parent = "0"
	path = "\resources\upload\textboxio\"
	name = addFileExtension(fso.GetFileName(uploadForm("image").FilePath), getNow())
	ip = User.data("userIp")

	If parentTable = "" Or parent = "" Then
		res.data("state") = "false"
		res.data("code") = "E1"
		res.data("message") = "입력되지 않은 항목이 있습니다."
		Response.Write res.JSONoutput()
		Response.End()
	End If

	uploadForm("image").SaveAs(server.mappath(path) & "\" & name)

	ReDim param(4)
	param(0) = DBHelper.MakeParam("@parentTable", adVarChar, adParamInput, 50, parentTable)
	param(1) = DBHelper.MakeParam("@parent", adVarChar, adParamInput, 10, parent)
	param(2) = DBHelper.MakeParam("@path", adVarChar, adParamInput, -1, path)
	param(3) = DBHelper.MakeParam("@name", adVarChar, adParamInput, -1, name)
	param(4) = DBHelper.MakeParam("@ip", adVarChar, adParamInput, 20, ip)
	Set rs = DBHelper.ExecSPReturnRS("setFile", param, Nothing)

	If Not rs.EOF And Not rs.BOF Then
'		res.data("idx") = rs("idx")
'		res.data("name") = rs("name")
'		res.data("state") = rs("state")
'		res.data("code") = rs("code")
'		res.data("message") = rs("message")
'		Response.Write res.JSONoutput()		
		Response.Write name
		Response.End()
	Else
		res.data("state") = "false"
		res.data("code") = "10"
		res.data("message") = "서버가 응답하지 않습니다."
		Response.Write res.JSONoutput()
		Response.End()
	End If

	DBHelper.Dispose
	Set DBHelper = Nothing
	Set uploadForm = Nothing
	Set fso = Nothing
	Set rs = Nothing
%>
