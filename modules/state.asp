<!-- #include virtual="/modules/Common.asp"  -->
<% ROLE = "user" %>
<!-- #include virtual="/modules/module_permission.asp"  -->
<%
	'on error resume Next
	ROLE = textFilter(Request("role"))
	
	Dim param

	If ROLE = "setState" Then
		className = textFilter(Request("class"))
		name = textFilter(Request("name"))		
		description = textFilter(Request("description"))
		perfection = textFilter(Request("perfection"))
		If name = "" Or description = "" Or perfection = "" Then
			res.data("state") = "false"
			res.data("code") = "01"
			res.data("message") = "입력하지 않은 항목이 있습니다."
			Response.Write res.JSONoutput()
			Response.End()
		End If

		ReDim param(3)
		param(0) = DBHelper.MakeParam("@class", adVarChar, adParamInput, 50, className)
		param(1) = DBHelper.MakeParam("@name", adVarChar, adParamInput, 50, name)			
		param(2) = DBHelper.MakeParam("@description", adVarChar, adParamInput, -1, description)
		param(3) = DBHelper.MakeParam("@perfection", adVarChar, adParamInput, 3, perfection)
		DBHelper.ExecSP "setState", param, Nothing

		res.data("state") = "true"
		res.data("code") = "00"
		res.data("message") = "추가 되었습니다."
		Response.Write res.JSONoutput()

	ElseIf ROLE = "getState" Then
		className = textFilter(Request("class"))

		ReDim param(0)
		param(0) = DBHelper.MakeParam("@class", adVarChar, adParamInput, 10, className)
		Set rs = DBHelper.ExecSPReturnRS("getState	", param, Nothing)
		If Not rs.EOF And Not rs.BOF Then			
			Set stateList = New aspJSON
			stateList.data.Add "list", stateList.Collection()
			Do Until rs.EOF
				Set row = stateList.AddToCollection(stateList.data("list"))
				row.add "idx", CStrN(rs("idx"))
				row.add "name", CStrN(rs("name"))
				row.add "description", CStrN(rs("description"))
				row.add "perfection", CStrN(rs("perfection"))
				rs.movenext()
			Loop
			Response.Write stateList.JSONoutput()
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