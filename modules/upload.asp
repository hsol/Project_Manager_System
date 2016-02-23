<%
   Response.Write(Replace("test.the.dot.txt","."&Split("test.the.dot.txt",".")(UBound(Split("test.the.dot.txt","."))), ""))
%>