<!-- #include virtual="/modules/Common.asp"  -->
<%
	'on error resume Next
	ROLE = textFilter(Request("role"))

	Dim param
	
	If ROLE = "login" Then
		id = textFilter(Request("id"))
		pw = textFilter(Request("pw"))
		
		ReDim param(1)
		param(0) = DBHelper.MakeParam("@id", adVarChar, adParamInput, 50, id)
		param(1) = DBHelper.MakeParam("@password", adVarChar, adParamInput,100, pw)
		Set rs = DBHelper.ExecSPReturnRS("loginCheck", param, Nothing)
		If Not rs.EOF Or Not rs.BOF Then
			User.loadJSON(Session("userInfo"))
			If rs("state") = "true" Then
				User.data("isLogin") = "true"
				User.data("userId") = rs("id")
				User.data("userName") = rs("name")
				User.data("userClass") = rs("class")
				Session("userInfo") = User.JSONoutput()

				res.data("state") = "true"
				res.data("code") = "00"
				res.data("message") = rs("name") & "님 안녕하세요."
			Else
				intraConnectionString = getConnectionString(intraDB.data("ip"), intraDB.data("name"), intraDB.data("id"), intraDB.data("pw"))
				queryString = "SELECT * FROM Tb_User WHERE EmpCode='" + id + "'"
				Set intraRs = DBHelper.ExecSQLReturnRS(queryString, param, intraConnectionString)

				If Not intraRs.EOF Or Not intraRs.BOF  Then
					If intraRs("PSWD_NM") = pw Then					
					ReDim param(5)
						param(0) = DBHelper.MakeParam("@part", adVarChar, adParamInput, 10, "4")
						param(1) = DBHelper.MakeParam("@id", adVarChar, adParamInput, 50, intraRs("EmpCode"))
						param(2) = DBHelper.MakeParam("@password", adVarChar, adParamInput,100, intraRs("PSWD_NM"))
						param(3) = DBHelper.MakeParam("@name", adVarChar, adParamInput,100, intraRs("EmpName"))
						param(4) = DBHelper.MakeParam("@duty", adVarChar, adParamInput,50, intraRs("Duty"))
						param(5) = DBHelper.MakeParam("@class", adVarChar, adParamInput,10, userClass.data("user"))
						Set rs = DBHelper.ExecSPReturnRS("createUser", param, Nothing)

						User.data("isLogin") = "true"
						User.data("userId") = intraRs("EmpCode")
						User.data("userName") = intraRs("EmpName")
						User.data("userClass") = intraRs("EmpCode") & "님 안녕하세요."
						Session("userInfo") = User.JSONoutput()

						res.data("state") = "true"
						res.data("code") = "00"
						res.data("message") = intraRs("EmpName") & "님 안녕하세요."
					Else
						User.data("isLogin") = "false"
						User.data("userId") = ""
						User.data("userName") = ""
						User.data("userClass") = ""
						Session("userInfo") = User.JSONoutput()

						res.data("state") = "false"
						res.data("code") = "01"
						res.data("message") = "아이디 또는 비밀번호가 잘못되었습니다."
					End If
				Else
					User.data("isLogin") = "false"
					User.data("userId") = ""
					User.data("userName") = ""
					User.data("userClass") = ""
					Session("userInfo") = User.JSONoutput()

					res.data("state") = "false"
					res.data("code") = "01"
					res.data("message") = "아이디 또는 비밀번호가 잘못되었습니다."
				End If
			End If
		Else
			res.data("state") = "false"
			res.data("code") = "10"
			res.data("message") = "서버가 응답하지 않습니다."
		End If
		Response.Write res.JSONoutput()

	ElseIf ROLE = "logout" Then
		Session.Contents.Remove("userInfo")
		res.data("state") = "true"
		res.data("code") = "00"
		res.data("message") = "로그아웃 되었습니다."
		Response.Write res.JSONoutput()
	ElseIf ROLE = "join" Then
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