<!-- #include virtual="/modules/Common.asp"  -->
<% ROLE = "user" %>
<!-- #include virtual="/modules/module_permission.asp"  -->
<%
	on error resume Next
	ROLE = textFilter(Request("role"))
	
	Dim param

	If ROLE = "getPart" Then
		Set rs = DBHelper.ExecSPReturnRS("getPart", Nothing, Nothing)

		If Not rs.EOF AND Not rs.BOF Then
			Set part = New aspJSON
			part.data.Add "list", part.Collection()
			Do Until rs.EOF OR rs.BOF
				Set row = part.AddToCollection (part.data ("list"))
				row.add "idx", CStr(rs("idx"))
				row.add "name", CStr(rs("name"))
				row.add "description", CStr(rs("description"))
				rs.movenext()
			Loop
			Response.Write part.JSONoutput()
		Else
			res.data("state") = "false"
			res.data("code") = "10"
			res.data("message") = "서버가 응답하지 않습니다."
			Response.Write res.JSONoutput()
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
%>