<!-- #include virtual="/modules/Common.asp"  -->
<%
	on error resume Next
	ROLE = textFilter(Request("role"))

	Dim param
	
	If ROLE = "getReplyList" Then
		PAGE = textFilter(Request("page"))
		RFP = textFilter(Request("rfp"))
		parentTable = textFilter(Request("parentTable"))
		parent = textFilter(Request("parent"))		

		ReDim param(3)
		param(0) = DBHelper.MakeParam("@PAGE", adInteger, adParamInput, -1, PAGE)		
		param(1) = DBHelper.MakeParam("@RFP", adInteger, adParamInput, -1, RFP)
		param(2) = DBHelper.MakeParam("@parentTable", adVarChar, adParamInput, 50, parentTable)
		param(3) = DBHelper.MakeParam("@parent", adVarChar, adParamInput, 10, parent)
		Set rs = DBHelper.ExecSPReturnRS("getReplyList", param, Nothing)

		If Not rs.EOF And Not rs.BOF Then
			Set replyList = New aspJSON
			replyList.data.Add "maxCount", ""	
			replyList.data.Add "list", replyList.Collection()
			Do Until rs.EOF
				Set row = replyList.AddToCollection(replyList.data("list"))
				row.add "page", CStr(rs("PAGE_IDX"))
				row.add "idx", CStr(rs("idx"))
				row.add "name", CStr(rs("name"))
				row.add "id", CStr(rs("id"))
				row.add "contents", CStr(rs("contents"))	
				row.add "created", CStr(rs("created"))	
				row.add "updated", CStr(rs("updated"))
				replyList.data("maxCount") = rs("MAX_COUNT")
				rs.movenext()
			Loop
			Response.Write replyList.JSONoutput()
		Else
			res.data("state") = "false"
			res.data("code") = "10"
			res.data("message") = "서버가 응답하지 않습니다."
			Response.Write res.JSONoutput()
		End If

	ElseIf ROLE = "insertReply" Then
		parentTable = textFilter(Request("parentTable"))		
		parent = textFilter(Request("parent"))
		userId = User.data("userId")
		contents = textFilter(Request("contents"))

		ReDim param(3)
		param(0) = DBHelper.MakeParam("@parentTable", adVarChar, adParamInput, 50, parentTable)
		param(1) = DBHelper.MakeParam("@parent", adVarChar, adParamInput, 10, parent)
		param(2) = DBHelper.MakeParam("@userId", adVarChar, adParamInput, 50, userId)
		param(3) = DBHelper.MakeParam("@contents", adVarChar, adParamInput, -1, contents)
		Set rs = DBHelper.ExecSPReturnRS("insertReply", param, Nothing)

		If Not rs.EOF And Not rs.BOF Then
			Set reply = New aspJSON
			reply.data.Add "idx", CStr(rs("idx"))
			reply.data.Add "name", CStr(rs("name"))
			reply.data.Add "id", CStr(rs("id"))
			reply.data.Add "contents", CStr(rs("contents"))	
			reply.data.Add "created", CStr(rs("created"))	
			reply.data.Add "updated", CStr(rs("updated"))
			Response.Write reply.JSONoutput()
		Else
			res.data("state") = "false"
			res.data("code") = "10"
			res.data("message") = "서버가 응답하지 않습니다."
			Response.Write res.JSONoutput()
		End If

	ElseIf ROLE = "updateReply" Then
		parentTable = textFilter(Request("parentTable"))		
		parent = textFilter(Request("parent"))
		idx = textFilter(Request("idx"))
		userId = User.data("userId")		
		contents = textFilter(Request("contents"))

		ReDim param(4)
		param(0) = DBHelper.MakeParam("@parentTable", adVarChar, adParamInput, 50, parentTable)
		param(1) = DBHelper.MakeParam("@parent", adVarChar, adParamInput, 10, parent)
		param(2) = DBHelper.MakeParam("@idx", adVarChar, adParamInput, 10, idx)
		param(3) = DBHelper.MakeParam("@userId", adVarChar, adParamInput, 50, userId)
		param(4) = DBHelper.MakeParam("@contents", adVarChar, adParamInput, -1, contents)
		Set rs = DBHelper.ExecSPReturnRS("updateReply", param, Nothing)

		If Not rs.EOF And Not rs.BOF Then
			Set reply = New aspJSON
			reply.data.Add "idx", CStr(rs("idx"))
			reply.data.Add "name", CStr(rs("name"))
			reply.data.Add "id", CStr(rs("id"))
			reply.data.Add "contents", CStr(rs("contents"))	
			reply.data.Add "created", CStr(rs("created"))	
			reply.data.Add "updated", CStr(rs("updated"))
			Response.Write reply.JSONoutput()
		Else
			res.data("state") = "false"
			res.data("code") = "10"
			res.data("message") = "서버가 응답하지 않습니다."
			Response.Write res.JSONoutput()
		End If

	Else
		Response.Write Session("userInfo")
		Response.End()
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