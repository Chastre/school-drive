<%-- 
    Document   : meus_alunos_instrutor
    Created on : 19/01/2026, 11:12:46
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page import="java.text.*"%>
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
<title>Meus Alunos - Drive School</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Work Sans',sans-serif;background:linear-gradient(135deg,#1a3a4d 0%,#800020 100%);background-attachment:fixed;color:white;min-height:100vh}
.topbar{background:rgba(0,0,0,0.4);backdrop-filter:blur(10px);padding:12px 30px;border-bottom:1px solid rgba(255,193,7,0.2);display:flex;justify-content:space-between;align-items:center}
.topbar-left{display:flex;align-items:center;gap:16px}
.topbar-left img{height:46px;filter:drop-shadow(0 0 8px rgba(255,193,7,0.3))}
.user-info{display:flex;align-items:center;gap:8px;font-size:.9rem}
.user-info i{color:#FFC107}
.btn-voltar{background:rgba(255,255,255,.1);color:white;padding:9px 22px;border-radius:25px;text-decoration:none;font-weight:600;border:2px solid rgba(255,255,255,.3);display:inline-flex;align-items:center;gap:7px;transition:all .3s}
.btn-voltar:hover{border-color:#FFC107;color:#FFC107}
.wrap{max-width:1200px;margin:0 auto;padding:35px 20px 60px}
.page-title{font-size:1.8rem;font-weight:800;margin-bottom:25px;display:flex;align-items:center;gap:12px}
.page-title i{color:#FFC107}
.alunos-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(360px,1fr));gap:22px}

/* CARD */
.aluno-card{background:rgba(255,255,255,.05);backdrop-filter:blur(10px);border:1px solid rgba(255,193,7,.2);border-radius:18px;padding:24px;transition:all .3s}
.aluno-card:hover{transform:translateY(-5px);border-color:#FFC107;box-shadow:0 12px 35px rgba(255,193,7,.2)}
.aluno-header{display:flex;align-items:center;gap:14px;margin-bottom:18px;padding-bottom:16px;border-bottom:1px solid rgba(255,193,7,.15)}
.aluno-avatar{width:52px;height:52px;border-radius:14px;background:linear-gradient(135deg,rgba(255,193,7,.3),rgba(255,193,7,.1));border:1px solid rgba(255,193,7,.3);display:flex;align-items:center;justify-content:center;flex-shrink:0}
.aluno-avatar i{font-size:1.5rem;color:#FFC107}
.aluno-nome{font-size:1.1rem;font-weight:700}
.aluno-email{font-size:.8rem;color:rgba(255,255,255,.5);margin-top:2px}

/* BADGES */
.badges-row{display:flex;gap:8px;flex-wrap:wrap;margin-bottom:16px}
.badge{font-size:.72rem;padding:4px 10px;border-radius:8px;font-weight:700;display:inline-flex;align-items:center;gap:5px}
.badge-verde{background:rgba(40,167,69,.25);color:#a8f0b8;border:1px solid rgba(40,167,69,.4)}
.badge-amarelo{background:rgba(255,193,7,.2);color:#FFC107;border:1px solid rgba(255,193,7,.35)}
.badge-cinza{background:rgba(255,255,255,.08);color:rgba(255,255,255,.5);border:1px solid rgba(255,255,255,.15)}
.badge-azul{background:rgba(33,150,243,.2);color:#90caf9;border:1px solid rgba(33,150,243,.35)}

/* PROGRESSO */
.progresso-bloco{margin-bottom:16px}
.progresso-row{display:flex;justify-content:space-between;align-items:center;font-size:.8rem;margin-bottom:5px}
.progresso-row span{color:rgba(255,255,255,.7)}
.progresso-row strong{color:white}
.barra{height:7px;background:rgba(255,255,255,.1);border-radius:6px;overflow:hidden}
.barra-fill{height:100%;border-radius:6px;transition:width .5s}
.barra-verde{background:linear-gradient(90deg,#28a745,#20c040)}
.barra-azul{background:linear-gradient(90deg,#2196F3,#1976D2)}
.barra-amarelo{background:linear-gradient(90deg,#FFC107,#FFB300)}

/* PROXIMA AULA */
.proxima-aula{border-radius:10px;padding:10px 14px;text-align:center;font-size:.85rem;font-weight:600;margin-top:14px;display:flex;align-items:center;justify-content:center;gap:8px}
.proxima-ativa{background:rgba(33,150,243,.2);color:#90caf9;border:1px solid rgba(33,150,243,.3)}
.proxima-vazia{background:rgba(255,255,255,.05);color:rgba(255,255,255,.35);border:1px solid rgba(255,255,255,.1)}

.empty-state{text-align:center;padding:60px 20px;color:rgba(255,255,255,.4);grid-column:1/-1}
.empty-state i{font-size:4rem;margin-bottom:20px;opacity:.3;display:block}
</style>
</head>
<body>
<div class="topbar">
    <div class="topbar-left">
        <a href="dashboard_instrutor.jsp"><img src="image/logo_mini.png" alt="Drive School"></a>
        <div class="user-info"><i class="fa fa-user-tie"></i><span><strong><%= username %></strong> (Instrutor)</span></div>
    </div>
    <a href="dashboard_instrutor.jsp" class="btn-voltar"><i class="fa fa-arrow-left"></i>Dashboard</a>
</div>

<div class="wrap">
    <div class="page-title"><i class="fa fa-users"></i>Meus Alunos</div>

    <div class="alunos-grid">
<%
Connection conn=null;PreparedStatement pstmt=null;ResultSet rs=null;
try{
    conn=ConexaoBD.getConnection();

    // Buscar id do instrutor
    pstmt=conn.prepareStatement("SELECT i.id FROM instrutor i WHERE i.email=(SELECT email FROM t_utilizador WHERE username=?)");
    pstmt.setString(1,username);rs=pstmt.executeQuery();
    Integer idInstrutor=null;
    if(rs.next()) idInstrutor=rs.getInt("id");
    rs.close();pstmt.close();

    if(idInstrutor!=null){
        // Buscar alunos com dados de condução + teóricas + código
        String sqlAlunos=
            "SELECT a.id, a.nome, a.email, a.acessoConducao, a.aprovadoCodigo, " +
            "COUNT(DISTINCT CASE WHEN ac.estado='Concluída' THEN ac.id END) as aulasRealizadas, " +
            "COUNT(DISTINCT CASE WHEN ac.estado='Agendada' THEN ac.id END) as aulasAgendadas, " +
            "COUNT(DISTINCT CASE WHEN ac.estado != 'cancelada' THEN ac.id END) as totalConducao, " +
            "COUNT(DISTINCT CASE WHEN at2.estado='realizada' THEN at2.id END) as totalTeorica, " +
            "MIN(CASE WHEN ac.estado='Agendada' AND ac.dataHoraInicio>NOW() THEN ac.dataHoraInicio END) as proximaAula " +
            "FROM aluno a " +
            "LEFT JOIN aula_conducao ac ON a.id=ac.idAluno " +
            "LEFT JOIN aula_teorica at2 ON a.id=at2.idAluno " +
            "WHERE a.idInstrutor=? GROUP BY a.id ORDER BY a.nome";
        pstmt=conn.prepareStatement(sqlAlunos);
        pstmt.setInt(1,idInstrutor);rs=pstmt.executeQuery();
        SimpleDateFormat sdf=new SimpleDateFormat("dd/MM/yyyy 'às' HH:mm");
        boolean temAlunos=false;

        while(rs.next()){
            temAlunos=true;
            String nome=rs.getString("nome");
            String email=rs.getString("email");
            int acessoConducao=rs.getInt("acessoConducao");
            int aprovadoCodigo=rs.getInt("aprovadoCodigo");
            int aulasRealizadas=rs.getInt("aulasRealizadas");
            int aulasAgendadas=rs.getInt("aulasAgendadas");
            int totalConducao=rs.getInt("totalConducao");
            int totalTeorica=rs.getInt("totalTeorica");
            Timestamp proximaAula=rs.getTimestamp("proximaAula");

            int limiteConducao = aprovadoCodigo==1 ? 30 : 15;
            int pctTeorica = Math.min(100, totalTeorica*5);
            int pctConducao = limiteConducao>0 ? Math.min(100, totalConducao*100/limiteConducao) : 0;
            int aulasRestantes = Math.max(0, limiteConducao - totalConducao);
%>
        <div class="aluno-card">
            <div class="aluno-header">
                <div class="aluno-avatar"><i class="fa fa-user-graduate"></i></div>
                <div>
                    <div class="aluno-nome"><%= nome %></div>
                    <div class="aluno-email"><%= email %></div>
                </div>
            </div>

            <!-- BADGES DE ESTADO -->
            <div class="badges-row">
                <% if(aprovadoCodigo==1){ %>
                <span class="badge badge-verde"><i class="fa fa-check-circle"></i>Código aprovado</span>
                <% } else { %>
                <span class="badge badge-cinza"><i class="fa fa-clock"></i>Código pendente</span>
                <% } %>
                <% if(acessoConducao==1){ %>
                <span class="badge badge-azul"><i class="fa fa-car"></i>Condução ativa</span>
                <% } else { %>
                <span class="badge badge-cinza"><i class="fa fa-lock"></i>Sem acesso condução</span>
                <% } %>
            </div>

            <!-- PROGRESSO TEÓRICAS -->
            <div class="progresso-bloco">
                <div class="progresso-row">
                    <span><i class="fa fa-chalkboard" style="margin-right:5px;color:#FFC107"></i>Aulas Teóricas</span>
                    <strong><%= totalTeorica %>/20</strong>
                </div>
                <div class="barra"><div class="barra-fill barra-amarelo" style="width:<%= pctTeorica %>%"></div></div>
            </div>

            <!-- PROGRESSO CONDUÇÃO -->
            <div class="progresso-bloco">
                <div class="progresso-row">
                    <span><i class="fa fa-car" style="margin-right:5px;color:#2196F3"></i>Aulas Condução</span>
                    <strong><%= totalConducao %>/<%= limiteConducao %> <span style="color:rgba(255,255,255,.4);font-weight:400">(faltam <%= aulasRestantes %>)</span></strong>
                </div>
                <div class="barra"><div class="barra-fill barra-azul" style="width:<%= pctConducao %>%"></div></div>
            </div>

            <!-- PRÓXIMA AULA -->
            <% if(proximaAula!=null){ %>
            <div class="proxima-aula proxima-ativa">
                <i class="fa fa-calendar-check"></i> Próxima: <%= sdf.format(proximaAula) %>
            </div>
            <% } else { %>
            <div class="proxima-aula proxima-vazia">
                <i class="fa fa-calendar-times"></i> Sem aulas agendadas
            </div>
            <% } %>
        </div>
<%
        }
        if(!temAlunos){
%>
        <div class="empty-state">
            <i class="fa fa-users"></i>
            <h3>Sem alunos atribuídos</h3>
            <p>Não tens alunos atribuídos no momento.</p>
        </div>
<%
        }
    }
}catch(Exception e){
    out.println("<p style='color:#f44336'>Erro: "+e.getMessage()+"</p>");
    e.printStackTrace();
}finally{
    try{if(rs!=null)rs.close();if(pstmt!=null)pstmt.close();if(conn!=null)conn.close();}catch(SQLException e){e.printStackTrace();}
}
%>
    </div>
</div>
</body>
</html>
