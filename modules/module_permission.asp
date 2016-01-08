<%
	If IsEmpty(ROLE) Then
	    ROLE = "all"
	End If

	If ROLE = "admin" Then
		If User.data("isLogin") = "false" Then
			res.data("state") = "false"
			res.data("code") = "99"
			res.data("message") = "로그인 해주세요."
			Response.Write res.JSONoutput()
			Response.End()
		Else
			If User.data("userClass") <> "admin" Then
				res.data("state") = "false"
				res.data("code") = "99"
				res.data("message") = "관리자로 로그인 해주세요."
				Response.Write res.JSONoutput()
				Response.End()
			End If
		End If
	ElseIf ROLE = "user" Then
		If User.data("isLogin") = "false" Then
			res.data("state") = "false"
			res.data("code") = "99"
			res.data("message") = "로그인 해주세요."
			Response.Write res.JSONoutput()
			Response.End()
		End If
	Else
	End If
%>