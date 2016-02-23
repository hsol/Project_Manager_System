<!-- #include virtual="/modules/Common.asp"  -->
<%
	'on error resume Next
	ROLE = textFilter(Request("role"))

	Dim param
	
	If ROLE = "getReplies" Then
		PAGE = textFilter(Request("page"))
		RFP = textFilter(Request("rfp"))
		parentTable = textFilter(Request("parentTable"))
		parent = textFilter(Request("parent"))		

		ReDim param(3)
		param(0) = DBHelper.MakeParam("@PAGE", adInteger, adParamInput, -1, PAGE)		
		param(1) = DBHelper.MakeParam("@RFP", adInteger, adParamInput, -1, RFP)
		param(2) = DBHelper.MakeParam("@parentTable", adVarChar, adParamInput, 50, parentTable)
		param(3) = DBHelper.MakeParam("@parent", adVarChar, adParamInput, 10, parent)
		Set rs = DBHelper.ExecSPReturnRS("getReplies", param, Nothing)

		If Not rs.EOF And Not rs.BOF Then
			Set replyList = New aspJSON
			replyList.data.Add "maxCount", ""	
			replyList.data.Add "list", replyList.Collection()
			Do Until rs.EOF
				Set row = replyList.AddToCollection(replyList.data("list"))
				row.add "page", CStrN(rs("PAGE_IDX"))
				row.add "idx", CStrN(rs("idx"))
				row.add "name", CStrN(rs("name"))
				row.add "id", CStrN(rs("id"))
				row.add "contents", CStrN(rs("contents"))	
				row.add "created", CStrN(rs("created"))	
				row.add "updated", CStrN(rs("updated"))
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
		contents = textFilter(Request("contents"))

		ReDim param(3)
		param(0) = DBHelper.MakeParam("@parentTable", adVarChar, adParamInput, 50, parentTable)
		param(1) = DBHelper.MakeParam("@parent", adVarChar, adParamInput, 10, parent)
		param(2) = DBHelper.MakeParam("@userId", adVarChar, adParamInput, 50, User.data("userId"))
		param(3) = DBHelper.MakeParam("@contents", adVarChar, adParamInput, -1, contents)
		Set rs = DBHelper.ExecSPReturnRS("insertReply", param, Nothing)

		If Not rs.EOF And Not rs.BOF Then
			Set reply = New aspJSON
			reply.data.Add "idx", CStrN(rs("idx"))
			reply.data.Add "name", CStrN(rs("name"))
			reply.data.Add "id", CStrN(rs("id"))
			reply.data.Add "contents", CStrN(rs("contents"))	
			reply.data.Add "created", CStrN(rs("created"))	
			reply.data.Add "updated", CStrN(rs("updated"))
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
		contents = textFilter(Request("contents"))

		ReDim param(4)
		param(0) = DBHelper.MakeParam("@parentTable", adVarChar, adParamInput, 50, parentTable)
		param(1) = DBHelper.MakeParam("@parent", adVarChar, adParamInput, 10, parent)
		param(2) = DBHelper.MakeParam("@idx", adVarChar, adParamInput, 10, idx)
		param(3) = DBHelper.MakeParam("@userId", adVarChar, adParamInput, 50, User.data("userId"))
		param(4) = DBHelper.MakeParam("@contents", adVarChar, adParamInput, -1, contents)
		Set rs = DBHelper.ExecSPReturnRS("updateReply", param, Nothing)

		If Not rs.EOF And Not rs.BOF Then
			res.data.Add "idx", CStrN(rs("idx"))
			res.data.Add "name", CStrN(rs("name"))
			res.data.Add "id", CStrN(rs("id"))
			res.data.Add "contents", CStrN(rs("contents"))	
			res.data.Add "created", CStrN(rs("created"))	
			res.data.Add "updated", CStrN(rs("updated"))
			res.data("state") = CStrN(rs("state"))
			res.data("code") = CStrN(rs("code"))
			res.data("message") = CStrN(rs("message"))
		Else
			res.data("state") = "false"
			res.data("code") = "10"
			res.data("message") = "서버가 응답하지 않습니다."
		End If
		Response.Write res.JSONoutput()

	ElseIf ROLE = "removeReply" Then
		idx = textFilter(Request("idx"))

		ReDim param(1)
		param(0) = DBHelper.MakeParam("@idx", adVarChar, adParamInput, 10, idx)
		param(1) = DBHelper.MakeParam("@userId", adVarChar, adParamInput, 50, User.data("userId"))
		Set rs = DBHelper.ExecSPReturnRS("removeReply", param, Nothing)

		If Not rs.EOF And Not rs.BOF Then
			res.data("state") = rs("state")
			res.data("code") = rs("code")
			res.data("message") = rs("message")
		Else
			res.data("state") = "false"
			res.data("code") = "10"
			res.data("message") = "서버가 응답하지 않습니다."			
		End If
		Response.Write res.JSONoutput()

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