<%-- 
    Document   : estatisticas_instrutor
    Created on : 19/01/2026, 11:13:38
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
if(session.getAttribute("logado")==null||!((Boolean)session.getAttribute("logado"))){response.sendRedirect("login.jsp");return;}
String tipo=(String)session.getAttribute("tipo");if(!"Instrutor".equals(tipo)){response.sendRedirect("login.jsp");return;}
String username=(String)session.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="pt">
<head>
<meta charset="utf-8">
<title>Estatísticas</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Work Sans',sans-serif;background:linear-gradient(135deg,#1a3a4d 0%,#800020 100%);background-attachment:fixed;color:white;min-height:100vh}
.topbar{background:rgba(0,0,0,0.4);backdrop-filter:blur(10px);padding:15px 0;border-bottom:1px solid rgba(255,193,7,0.2)}
.topbar .container{max-width:1400px;margin:0 auto;padding:0 20px;display:flex;justify-content:space-between;align-items:center}
.topbar .user-info{display:flex;align-items:center;gap:10px}
.topbar .user-info i{color:#FFC107}
.btn-sair{background:rgba(128,0,32,0.8);color:white;padding:10px 25px;border-radius:10px;text-decoration:none;font-weight:600;transition:all 0.3s;display:inline-flex;align-items:center;gap:8px;border:1px solid rgba(255,193,7,0.3)}
.btn-sair:hover{background:#800020;transform:translateY(-2px)}
.container{max-width:1400px;margin:0 auto;padding:40px 20px}
.logo-link{display:block;text-align:center;margin-bottom:30px;text-decoration:none}
.logo-link img{height:60px;filter:drop-shadow(0 0 10px rgba(255,193,7,0.3))}
.page-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:30px;flex-wrap:wrap;gap:20px}
.page-header h1{font-size:2rem;display:flex;align-items:center;gap:15px}
.page-header h1 i{color:#FFC107}
.btn{padding:12px 25px;border-radius:10px;font-size:1rem;font-weight:600;text-decoration:none;display:inline-flex;align-items:center;gap:8px;transition:all 0.3s;background:rgba(255,255,255,0.1);color:white;border:2px solid rgba(255,255,255,0.3)}
.btn:hover{background:rgba(255,255,255,0.2);border-color:#FFC107}
.stats-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(250px,1fr));gap:20px;margin-bottom:30px}
.stat-box{background:rgba(255,255,255,0.05);backdrop-filter:blur(10px);border:1px solid rgba(255,193,7,0.2);border-radius:15px;padding:30px;text-align:center;transition:all 0.3s}
.stat-box:hover{transform:translateY(-5px);border-color:#FFC107}
.stat-box i{font-size:3rem;color:#FFC107;margin-bottom:15px}
.stat-value{font-size:2.5rem;font-weight:700;color:white;margin:10px 0}
.stat-label{font-size:1rem;color:rgba(255,255,255,0.7)}
.chart-container{background:rgba(255,255,255,0.05);backdrop-filter:blur(10px);border:1px solid rgba(255,193,7,0.2);border-radius:15px;padding:30px;margin-bottom:20px}
.chart-container h3{color:#FFC107;margin-bottom:20px;font-size:1.5rem}
.bar-chart{display:flex;flex-direction:column;gap:15px}
.bar{min-width:150px;height:50px;display:flex;align-items:center;padding:0 20px;border-radius:10px;color:white;font-weight:600;transition:all 0.3s;position:relative;overflow:hidden}
.bar:hover{transform:scaleX(1.02);box-shadow:0 5px 15px rgba(0,0,0,0.3)}
.bar-label{position:relative;z-index:1}
.bar-agendada{background:linear-gradient(90deg,rgba(33,150,243,0.5),rgba(33,150,243,0.8))}
.bar-concluida{background:linear-gradient(90deg,rgba(76,175,80,0.5),rgba(76,175,80,0.8))}
.bar-cancelada{background:linear-gradient(90deg,rgba(244,67,54,0.5),rgba(244,67,54,0.8))}
@media(max-width:768px){.stats-grid{grid-template-columns:1fr}}
</style>
</head>
<body>
<div class="topbar">
<div class="container">
<div class="user-info"><i class="fa fa-user-tie"></i><span><strong><%=username%></strong> (Instrutor)</span></div>
<a href="logout.jsp" class="btn-sair"><i class="fa fa-sign-out-alt"></i>Sair</a>
</div>
</div>
<div class="container">
<a href="dashboard_instrutor.jsp" class="logo-link"><img src="image/logo_mini.png" alt="Drive School"></a>
<div class="page-header">
<h1><i class="fa fa-chart-line"></i>Estatísticas</h1>
<a href="dashboard_instrutor.jsp" class="btn"><i class="fa fa-arrow-left"></i>Voltar</a>
</div>
<%
Connection conn=null;PreparedStatement pstmt=null;ResultSet rs=null;
int agendadas=0,concluidas=0,canceladas=0;
double horasTotais=0;
String alunoTop="N/A";
int aulasMes=0;
try{
conn=ConexaoBD.getConnection();
String sqlInstrutor="SELECT i.id FROM instrutor i WHERE i.email=(SELECT email FROM t_utilizador WHERE username=?)";
pstmt=conn.prepareStatement(sqlInstrutor);pstmt.setString(1,username);rs=pstmt.executeQuery();
Integer idInstrutor=null;if(rs.next())idInstrutor=rs.getInt("id");rs.close();pstmt.close();
if(idInstrutor!=null){
pstmt=conn.prepareStatement("SELECT COUNT(CASE WHEN estado='Agendada' THEN 1 END) as agendadas,"+
"COUNT(CASE WHEN estado='Concluída' THEN 1 END) as concluidas,"+
"COUNT(CASE WHEN estado='Cancelada' THEN 1 END) as canceladas FROM aula_conducao WHERE idInstrutor=?");
pstmt.setInt(1,idInstrutor);rs=pstmt.executeQuery();
if(rs.next()){agendadas=rs.getInt("agendadas");concluidas=rs.getInt("concluidas");canceladas=rs.getInt("canceladas");}
rs.close();pstmt.close();
pstmt=conn.prepareStatement("SELECT SUM(TIMESTAMPDIFF(MINUTE,dataHoraInicio,dataHoraFim))/60.0 as horas FROM aula_conducao WHERE idInstrutor=? AND estado='Concluída'");
pstmt.setInt(1,idInstrutor);rs=pstmt.executeQuery();
if(rs.next())horasTotais=rs.getDouble("horas");rs.close();pstmt.close();
pstmt=conn.prepareStatement("SELECT a.nome,COUNT(*) as total FROM aula_conducao ac JOIN aluno a ON ac.idAluno=a.id WHERE ac.idInstrutor=? AND ac.estado='Concluída' GROUP BY a.id ORDER BY total DESC LIMIT 1");
pstmt.setInt(1,idInstrutor);rs=pstmt.executeQuery();
if(rs.next())alunoTop=rs.getString("nome");rs.close();pstmt.close();
pstmt=conn.prepareStatement("SELECT COUNT(*) as total FROM aula_conducao WHERE idInstrutor=? AND MONTH(dataHoraInicio)=MONTH(CURDATE()) AND YEAR(dataHoraInicio)=YEAR(CURDATE())");
pstmt.setInt(1,idInstrutor);rs=pstmt.executeQuery();
if(rs.next())aulasMes=rs.getInt("total");
}
}catch(Exception e){out.println("<p style='color:#f44336'>Erro: "+e.getMessage()+"</p>");e.printStackTrace();
}finally{try{if(rs!=null)rs.close();if(pstmt!=null)pstmt.close();if(conn!=null)conn.close();}catch(SQLException e){e.printStackTrace();}}
int totalAulas=agendadas+concluidas+canceladas;
int maxAulas=Math.max(Math.max(agendadas,concluidas),Math.max(canceladas,1));
%>
<div class="stats-grid">
<div class="stat-box">
<i class="fa fa-calendar-check"></i>
<div class="stat-value"><%=concluidas%></div>
<div class="stat-label">Aulas Concluídas</div>
</div>
<div class="stat-box">
<i class="fa fa-clock"></i>
<div class="stat-value"><%=String.format("%.1f",horasTotais)%>h</div>
<div class="stat-label">Horas de Condução</div>
</div>
<div class="stat-box">
<i class="fa fa-user-graduate"></i>
<div class="stat-value" style="font-size:1.5rem"><%=alunoTop%></div>
<div class="stat-label">Aluno Mais Frequente</div>
</div>
<div class="stat-box">
<i class="fa fa-calendar-alt"></i>
<div class="stat-value"><%=aulasMes%></div>
<div class="stat-label">Aulas Este Mês</div>
</div>
</div>
<div class="chart-container">
<h3><i class="fa fa-chart-bar"></i> Aulas por Estado</h3>
<div class="bar-chart">
<div class="bar bar-agendada" style="width:<%=Math.max((agendadas*100/maxAulas),15)%>%">
<span class="bar-label">Agendadas: <%=agendadas%></span>
</div>
<div class="bar bar-concluida" style="width:<%=Math.max((concluidas*100/maxAulas),15)%>%">
<span class="bar-label">Concluídas: <%=concluidas%></span>
</div>
<div class="bar bar-cancelada" style="width:<%=Math.max((canceladas*100/maxAulas),15)%>%">
<span class="bar-label">Canceladas: <%=canceladas%></span>
</div>
</div>
</div>
</div>
</body>
</html>
