<%
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
%>