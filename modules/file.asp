<!-- #include virtual="/modules/Common.asp"  -->
<% ROLE = "user" %>
<!-- #include virtual="/modules/module_permission.asp"  -->
<%
	on error resume Next
	ROLE = textFilter(Request("role"))
	If ROLE = "" Then
		ROLE = "upload"
	End If
	
	Dim param

	If ROLE = "download" Then
		parentTable = textFilter(Request("parentTable"))
		parent = textFilter(Request("parent"))
		idx = textFilter(Request("idx"))

		ReDim param(2)
		param(0) = DBHelper.MakeParam("@parentTable", adVarChar, adParamInput, 50, parentTable)
		param(1) = DBHelper.MakeParam("@parent", adVarChar, adParamInput, 10, parent)
		param(2) = DBHelper.MakeParam("@idx", adVarChar, adParamInput, 10, idx)
		Set rs = DBHelper.ExecSPReturnRS("getFile", param, Nothing)

		If Not rs.EOF And Not rs.BOF Then		
			name = rs("name")
			path = rs("path")
		Else
			name = ""
			path = ""
		End If

		if name = "" or path = "" then
			AlertBack "존재하지 않는 파일입니다. 다시 한번 확인해주세요."
			Response.end
		End If
		
		file = Server.MapPath(path)&"\"& name
		
		if isFileNotExist(file) then
			AlertBack "존재하지 않는 파일입니다."
			Response.end
		End If

		Response.Clear
		Response.ContentType = "application/octet_stream"
		Response.AddHeader "Content-Disposition","attachment;filename=" & Server.URLPathEncode(name) & ""
		Response.AddHeader "Content-Transfer-Encoding", "binary"
		Response.AddHeader "Pragma", "no-cache"
		Response.AddHeader "Expires", "0"
			
		' Stream 선언
		Set objStream = Server.CreateObject("ADODB.Stream")
		objStream.Open
		objStream.Type = 1
		objStream.LoadFromFile file
		strFile = objStream.Read
		Response.BinaryWrite strFile
		Set objStream = Nothing

	ElseIf ROLE = "upload" Then
		Set uploadForm = Server.CreateObject ("SiteGalaxyUpload.Form")
		Set fso = Server.CreateObject("Scripting.FileSystemObject")

		parentTable = textFilter(uploadForm("parentTable"))
		parent = textFilter(uploadForm("parent"))
		path = textFilter(uploadForm("path"))
		name = textFilter(uploadForm("name"))
		ip = User.data("userIp")

		If path = "" Then
			path = "\resources\upload\"
		End If
		If name = "" Then
			name = fso.GetFileName(uploadForm("FILE").FilePath)
		End If

		name = addAtLastOfFilePath(name, "_"&getNow())

		If parentTable = "" Or parent = "" Then
			res.data("state") = "false"
			res.data("code") = "E1"
			res.data("message") = "입력되지 않은 항목이 있습니다."
			Response.Write res.JSONoutput()
			Response.End()
		End If

		uploadForm("FILE").SaveAs(server.mappath(path) & "\" & name)

		ReDim param(4)
		param(0) = DBHelper.MakeParam("@parentTable", adVarChar, adParamInput, 50, parentTable)
		param(1) = DBHelper.MakeParam("@parent", adVarChar, adParamInput, 10, parent)
		param(2) = DBHelper.MakeParam("@path", adVarChar, adParamInput, -1, path)
		param(3) = DBHelper.MakeParam("@name", adVarChar, adParamInput, -1, name)
		param(4) = DBHelper.MakeParam("@ip", adVarChar, adParamInput, 20, ip)

		Set rs = DBHelper.ExecSPReturnRS("setFile", param, Nothing)

		If Not rs.EOF And Not rs.BOF Then			
			res.data("idx") = rs("idx")
			res.data("name") = rs("name")
			res.data("state") = rs("state")
			res.data("code") = rs("code")
			res.data("message") = rs("message")
			Response.Write res.JSONoutput()
			Response.End()
		Else
			res.data("state") = "false"
			res.data("code") = "10"
			res.data("message") = "서버가 응답하지 않습니다."
			Response.Write res.JSONoutput()
			Response.End()
		End If
		
	ElseIf ROLE = "remove" Then
		parentTable = textFilter(Request("parentTable"))
		parent = textFilter(Request("parent"))
		idx = textFilter(Request("idx"))

		ReDim param(2)
		param(0) = DBHelper.MakeParam("@parentTable", adVarChar, adParamInput, 50, parentTable)
		param(1) = DBHelper.MakeParam("@parent", adVarChar, adParamInput, 10, parent)
		param(2) = DBHelper.MakeParam("@idx", adVarChar, adParamInput, 10, idx)

		Set rs = DBHelper.ExecSPReturnRS("removeFile", param, Nothing)

		If Not rs.EOF And Not rs.BOF Then
			res.data("state") = rs("state")
			res.data("code") = rs("code")
			res.data("message") = rs("message")
			Response.Write res.JSONoutput()
			Response.End()	
		Else
			res.data("state") = "false"
			res.data("code") = "10"
			res.data("message") = "서버가 응답하지 않습니다."
			Response.Write res.JSONoutput()
			Response.End()
		End If

	Else
		Response.Write Session("userInfo")
	End If

	If Err.Number <> 0 Then
		Response.Clear()
		res.data("state") = "false"
		res.data("code") = Err.Number
		res.data("message") = Err.Description
		Response.Write res.JSONoutput()
	End If

	DBHelper.Dispose
	Set DBHelper = Nothing
	Set uploadForm = Nothing
	Set fso = Nothing
	Set rs = Nothing
	Set file = Nothing
%>