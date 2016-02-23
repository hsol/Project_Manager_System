<%
	Response.charset = "utf-8"

	Function textFilter(str)
		str = Replace(str,"'","''")
		str = Replace(str,"\","\\")
		str = Replace(str, "<", "&lt;")
		str = Replace(str, ">", "&gt;")
		str = Replace(str, chr(0), "")

		textFilter = str
		If Err.number <> 0 Then textFilter = ""
	End Function

	Function getPath()
        query_string = Request.ServerVariables("QUERY_STRING")
        if query_string <> "" then
            query_string = "?" & query_string
        end if
        getPath = "http://" & Request.ServerVariables("SERVER_NAME") & ":" & Request.ServerVariables("SERVER_PORT") & Request.ServerVariables("URL") & query_string
	End Function

	Sub AlertGo(str, location)
        Response.Write "<script>"
        Response.Write "alert('" & str & "');"
        Response.Write "location.href = '" & location & "';"
        Response.Write "</script>"
		Response.End()
	End Sub

	Sub AlertBack(str)
        Response.Write "<script>"
        Response.Write "alert('" & str & "');"
        Response.Write "history.back()"
        Response.Write "</script>"
		Response.End()
	End Sub

	Function isFileNotExist(filePath)
	  Dim fso, result
	  Set fso = CreateObject("Scripting.FileSystemObject")
	  If fso.FileExists(filePath) Then
		isFileNotExist = false
	  Else
		isFileNotExist = true
	  End If
	End Function

	Function getConnectionString(IP, DB, ID, PW)
		getConnectionString = "Provider=SQLOLEDB;Data Source=" & IP & ";Initial Catalog=" & DB & ";User Id=" & ID & ";Password=" & PW & ";"
	End Function

	Function CStrN(column)
		If Not IsNull(column) Then
			CStrN = CStr(column)
		Else
			CStrN = ""
		End If
	End Function

	Sub JsonResponse(STATE, CODE, MESSAGE)
		res.data("state") = STATE
		res.data("code") = CODE
		res.data("message") = MESSAGE
		Response.Write res.JSONoutput()
	End Sub

	Sub JsonResponsed(STATE, CODE, MESSAGE)
		res.data("state") = STATE
		res.data("code") = CODE
		res.data("message") = MESSAGE
		Response.Write res.JSONoutput()
		Response.End()
	End Sub

	Sub displayRequest(methodtype)
		Dim strFormName
		If methodtype = "GET" Then
			For Each strFormName In Request.QueryString
				Response.Write strFormName & " : " & Request.QueryString(strFormName) & "<br>" & vbCrLf
			Next
		ElseIf methodtype = "POST" Then
			For Each strFormName In Request.Form
				Response.Write strFormName & " : " & Request.Form(strFormName) & "<br>" & vbCrLf
			Next
		End If
	End Sub

	Function getNow()
		getNow = Replace(Replace(FormatDateTime(Now(), 2)&FormatDateTime(Time(), 4)&Right(Now(), 3),"-",""),":","")
	End Function

	Function addAtLastOfFilePath(FilePath, addText)
		FileExtension = "."&Split(FilePath,".")(UBound(Split(FilePath,".")))
		FileName = Replace(FilePath,"."&Split(FilePath,".")(UBound(Split(FilePath,"."))), "")
		addAtLastOfFilePath = FileName & addText & FileExtension
	End Function

	Function addFileExtension(FilePath, addText)
		FileExtension = "."&Split(FilePath,".")(UBound(Split(FilePath,".")))
		addFileExtension = addText & FileExtension
	End Function	
%>