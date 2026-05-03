<%-- 
    Document   : minhas_aulas_instrutor
    Created on : 19/01/2026, 10:46:58
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page import="java.util.*"%>
<%@page import="java.text.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("logado") == null || !((Boolean)session.getAttribute("logado"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    String tipo = (String) session.getAttribute("tipo");
    if (!"Instrutor".equals(tipo)) {
        response.sendRedirect("login.jsp");
        return;
    }
    String username = (String) session.getAttribute("username");
    
    // ===== NAVEGAÇÃO DE SEMANAS =====
    String semanaParam = request.getParameter("semana");
    int offsetSemana = 0;
    if (semanaParam != null) {
        try {
            offsetSemana = Integer.parseInt(semanaParam);
        } catch (NumberFormatException e) {
            offsetSemana = 0;
        }
    }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="utf-8">
    <title>Horário Semanal</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Work Sans', sans-serif; background: linear-gradient(135deg, #1a3a4d 0%, #800020 100%); background-attachment: fixed; color: white; min-height: 100vh; }
        .topbar { background: rgba(0, 0, 0, 0.4); backdrop-filter: blur(10px); padding: 15px 0; border-bottom: 1px solid rgba(255, 193, 7, 0.2); }
        .topbar .container { max-width: 1600px; margin: 0 auto; padding: 0 20px; display: flex; justify-content: space-between; align-items: center; }
        .topbar .user-info { display: flex; align-items: center; gap: 10px; }
        .topbar .user-info i { color: #FFC107; }
        .btn-sair { background: rgba(128, 0, 32, 0.8); color: white; padding: 10px 25px; border-radius: 10px; text-decoration: none; font-weight: 600; transition: all 0.3s; display: inline-flex; align-items: center; gap: 8px; border: 1px solid rgba(255, 193, 7, 0.3); }
        .btn-sair:hover { background: #800020; transform: translateY(-2px); }
        .container { max-width: 1600px; margin: 0 auto; padding: 40px 20px; }
        .logo-link { display: block; text-align: center; margin-bottom: 30px; text-decoration: none; }
        .logo-link img { height: 60px; filter: drop-shadow(0 0 10px rgba(255, 193, 7, 0.3)); }
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; flex-wrap: wrap; gap: 20px; }
        .page-header h1 { font-size: 2rem; display: flex; align-items: center; gap: 15px; }
        .page-header h1 i { color: #FFC107; }
        .btn { padding: 12px 25px; border-radius: 10px; font-size: 1rem; font-weight: 600; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; transition: all 0.3s; background: rgba(255, 255, 255, 0.1); color: white; border: 2px solid rgba(255, 255, 255, 0.3); }
        .btn:hover { background: rgba(255, 255, 255, 0.2); border-color: #FFC107; }
        .nav-semana { background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(10px); border: 1px solid rgba(255, 193, 7, 0.2); border-radius: 15px; padding: 20px; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px; }
        .nav-semana .btn-nav { background: rgba(255, 193, 7, 0.2); color: #FFC107; padding: 10px 20px; border-radius: 10px; text-decoration: none; font-weight: 600; border: 1px solid #FFC107; display: inline-flex; align-items: center; gap: 8px; transition: all 0.3s; }
        .nav-semana .btn-nav:hover { background: rgba(255, 193, 7, 0.4); transform: scale(1.05); }
        .nav-semana .info-semana { text-align: center; flex: 1; min-width: 200px; }
        .nav-semana .label-semana { font-size: 0.9rem; color: rgba(255, 255, 255, 0.7); margin-bottom: 5px; }
        .nav-semana .range-semana { font-size: 1.2rem; font-weight: 700; color: #FFC107; }
        .alert-success { background: rgba(76, 175, 80, 0.2); border: 1px solid #4CAF50; border-radius: 10px; padding: 15px; margin-bottom: 20px; color: #4CAF50; display: flex; align-items: center; gap: 10px; }
        .calendar-container { background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(10px); border: 1px solid rgba(255, 193, 7, 0.2); border-radius: 20px; padding: 30px; overflow-x: auto; }
        .calendar-table { width: 100%; border-collapse: collapse; min-width: 1200px; }
        .calendar-table thead th { background: rgba(255, 193, 7, 0.2); padding: 15px; text-align: center; font-weight: 700; border: 1px solid rgba(255, 193, 7, 0.3); color: #FFC107; font-size: 0.95rem; }
        .calendar-table thead th:first-child { background: rgba(0, 0, 0, 0.3); color: white; width: 100px; }
        .calendar-table tbody td { border: 1px solid rgba(255, 255, 255, 0.1); padding: 10px; vertical-align: top; min-height: 80px; }
        .calendar-table tbody td:first-child { background: rgba(0, 0, 0, 0.2); text-align: center; font-weight: 600; color: #FFC107; }
        .aula-block { background: linear-gradient(135deg, rgba(33, 150, 243, 0.3), rgba(33, 150, 243, 0.5)); border-left: 3px solid #2196F3; padding: 10px; margin: 2px 0; border-radius: 5px; font-size: 0.9rem; transition: all 0.3s; }
        .aula-block:hover { background: linear-gradient(135deg, rgba(33, 150, 243, 0.5), rgba(33, 150, 243, 0.7)); box-shadow: 0 5px 15px rgba(33, 150, 243, 0.3); }
        .aula-block-concluida { background: linear-gradient(135deg, rgba(76, 175, 80, 0.3), rgba(76, 175, 80, 0.5)); border-left-color: #4CAF50; }
        .aula-block-cancelada { background: linear-gradient(135deg, rgba(244, 67, 54, 0.3), rgba(244, 67, 54, 0.5)); border-left-color: #f44336; opacity: 0.7; }
        .aula-aluno { font-weight: 700; color: white; display: block; margin-bottom: 5px; }
        .aula-hora { font-size: 0.85rem; color: rgba(255, 255, 255, 0.9); margin-bottom: 8px; }
        .aula-acoes { display: flex; gap: 5px; flex-wrap: wrap; }
        .btn-acao { padding: 5px 10px; border-radius: 5px; font-size: 0.75rem; font-weight: 600; text-decoration: none; border: none; cursor: pointer; transition: all 0.2s; }
        .btn-concluir { background: rgba(76, 175, 80, 0.3); color: #4CAF50; border: 1px solid #4CAF50; }
        .btn-concluir:hover { background: rgba(76, 175, 80, 0.6); transform: scale(1.05); }
        .btn-cancelar { background: rgba(244, 67, 54, 0.3); color: #f44336; border: 1px solid #f44336; }
        .btn-cancelar:hover { background: rgba(244, 67, 54, 0.6); transform: scale(1.05); }
        .hoje { background: rgba(255, 193, 7, 0.1) !important; }
        .legenda { display: flex; gap: 20px; margin-top: 20px; flex-wrap: wrap; }
        .legenda-item { display: flex; align-items: center; gap: 8px; }
        .legenda-cor { width: 20px; height: 20px; border-radius: 4px; }
        .cor-agendada { background: #2196F3; }
        .cor-concluida { background: #4CAF50; }
        .cor-cancelada { background: #f44336; }
        @media(max-width: 768px) { .calendar-container { padding: 15px; } .page-header h1 { font-size: 1.5rem; } }
    </style>
</head>
<body>
    <div class="topbar">
        <div class="container">
            <div class="user-info">
                <i class="fa fa-user-tie"></i>
                <span><strong><%= username %></strong> (Instrutor)</span>
            </div>
            <a href="logout.jsp" class="btn-sair">
                <i class="fa fa-sign-out-alt"></i>
                Sair
            </a>
        </div>
    </div>

    <div class="container">
        <a href="dashboard_instrutor.jsp" class="logo-link">
            <img src="image/logo_mini.png" alt="Drive School">
        </a>

        <div class="page-header">
            <h1><i class="fa fa-calendar-week"></i>Horário Semanal</h1>
            <a href="dashboard_instrutor.jsp" class="btn">
                <i class="fa fa-arrow-left"></i>
                Voltar
            </a>
        </div>

        <%
            String sucesso = request.getParameter("sucesso");
            if ("1".equals(sucesso)) {
        %>
            <div class="alert-success">
                <i class="fa fa-check-circle"></i>
                Estado da aula atualizado com sucesso!
            </div>
        <% } %>

        <div class="nav-semana">
            <a href="?semana=<%= offsetSemana - 1 %>" class="btn-nav">
                <i class="fa fa-chevron-left"></i>
                Semana Anterior
            </a>
            <div class="info-semana">
                <div class="label-semana">
                    <%= offsetSemana == 0 ? "SEMANA ATUAL" : (offsetSemana > 0 ? "+" + offsetSemana + " semanas" : offsetSemana + " semanas") %>
                </div>
                <div class="range-semana" id="rangoSemana"></div>
            </div>
            <a href="?semana=<%= offsetSemana + 1 %>" class="btn-nav">
                Próxima Semana
                <i class="fa fa-chevron-right"></i>
            </a>
        </div>

        <div class="calendar-container">
            <%
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                
                try {
                    conn = ConexaoBD.getConnection();
                    
                    String sqlInstrutor = "SELECT i.id FROM instrutor i WHERE i.email = (SELECT email FROM t_utilizador WHERE username = ?)";
                    pstmt = conn.prepareStatement(sqlInstrutor);
                    pstmt.setString(1, username);
                    rs = pstmt.executeQuery();
                    
                    Integer idInstrutor = null;
                    if (rs.next()) {
                        idInstrutor = rs.getInt("id");
                    }
                    rs.close();
                    pstmt.close();
                    
                    if (idInstrutor != null) {
                        Calendar hoje = Calendar.getInstance();
                        Calendar inicioSemana = (Calendar) hoje.clone();
                        
                        // Ajustar para segunda-feira + offset
                        inicioSemana.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);
                        inicioSemana.add(Calendar.WEEK_OF_YEAR, offsetSemana);
                        
                        SimpleDateFormat sdfDia = new SimpleDateFormat("EEEE", new Locale("pt", "PT"));
                        SimpleDateFormat sdfData = new SimpleDateFormat("dd/MM");
                        SimpleDateFormat sdfSQL = new SimpleDateFormat("yyyy-MM-dd");
                        SimpleDateFormat sdfRango = new SimpleDateFormat("dd/MM/yyyy");
                        
                        String[] diasSemana = new String[7];
                        String[] datasSemana = new String[7];
                        String[] datasSemanaSQL = new String[7];
                        
                        Calendar fimSemana = (Calendar) inicioSemana.clone();
                        fimSemana.add(Calendar.DAY_OF_MONTH, 6);
                        
                        String rangoSemana = sdfRango.format(inicioSemana.getTime()) + " - " + sdfRango.format(fimSemana.getTime());
                        
                        for (int i = 0; i < 7; i++) {
                            Calendar dia = (Calendar) inicioSemana.clone();
                            dia.add(Calendar.DAY_OF_MONTH, i);
                            diasSemana[i] = sdfDia.format(dia.getTime());
                            datasSemana[i] = sdfData.format(dia.getTime());
                            datasSemanaSQL[i] = sdfSQL.format(dia.getTime());
                        }
                        
                        String sqlAulas = "SELECT ac.id as idAula, ac.*, a.nome as nomeAluno, " +
                                        "DATE(ac.dataHoraInicio) as dataAula, " +
                                        "TIME_FORMAT(ac.dataHoraInicio, '%H:%i') as horaInicio, " +
                                        "TIME_FORMAT(ac.dataHoraFim, '%H:%i') as horaFim, " +
                                        "HOUR(ac.dataHoraInicio) as horaSlot " +
                                        "FROM aula_conducao ac " +
                                        "JOIN aluno a ON ac.idAluno = a.id " +
                                        "WHERE ac.idInstrutor = ? AND DATE(ac.dataHoraInicio) BETWEEN ? AND ? " +
                                        "ORDER BY ac.dataHoraInicio";
                        
                        pstmt = conn.prepareStatement(sqlAulas);
                        pstmt.setInt(1, idInstrutor);
                        pstmt.setString(2, datasSemanaSQL[0]);
                        pstmt.setString(3, datasSemanaSQL[6]);
                        rs = pstmt.executeQuery();
                        
                        Map<String, Map<Integer, List<Map<String, String>>>> aulasPorDiaHora = new HashMap<>();
                        for (String data : datasSemanaSQL) {
                            aulasPorDiaHora.put(data, new HashMap<>());
                            for (int h = 8; h <= 20; h++) {
                                aulasPorDiaHora.get(data).put(h, new ArrayList<>());
                            }
                        }
                        
                        while (rs.next()) {
                            String dataAula = rs.getString("dataAula");
                            int horaSlot = rs.getInt("horaSlot");
                            Map<String, String> aula = new HashMap<>();
                            aula.put("idAula", String.valueOf(rs.getInt("idAula")));
                            aula.put("aluno", rs.getString("nomeAluno"));
                            aula.put("horaInicio", rs.getString("horaInicio"));
                            aula.put("horaFim", rs.getString("horaFim"));
                            aula.put("estado", rs.getString("estado"));
                            if (aulasPorDiaHora.containsKey(dataAula)) {
                                aulasPorDiaHora.get(dataAula).get(horaSlot).add(aula);
                            }
                        }
                        
                        String hojeSql = sdfSQL.format(hoje.getTime());
            %>
                        <script>
                            document.getElementById('rangoSemana').textContent = '<%= rangoSemana %>';
                        </script>
                        
                        <table class="calendar-table">
                            <thead>
                                <tr>
                                    <th>Hora</th>
                                    <% for (int i = 0; i < 7; i++) {
                                        String classeHoje = datasSemanaSQL[i].equals(hojeSql) ? "hoje" : "";
                                    %>
                                        <th class="<%= classeHoje %>">
                                            <%= diasSemana[i] %><br>
                                            <small><%= datasSemana[i] %></small>
                                        </th>
                                    <% } %>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (int hora = 8; hora <= 20; hora++) {
                                    String horaStr = String.format("%02d:00", hora);
                                %>
                                    <tr>
                                        <td><%= horaStr %></td>
                                        <% for (int i = 0; i < 7; i++) {
                                            String classeHoje = datasSemanaSQL[i].equals(hojeSql) ? "hoje" : "";
                                            List<Map<String, String>> aulasNaHora = aulasPorDiaHora.get(datasSemanaSQL[i]).get(hora);
                                        %>
                                            <td class="<%= classeHoje %>">
                                                <% for (Map<String, String> aula : aulasNaHora) {
                                                    String estado = aula.get("estado");
                                                    String classeEstado = "";
                                                    if ("Concluída".equals(estado)) {
                                                        classeEstado = "aula-block-concluida";
                                                    } else if ("Cancelada".equals(estado)) {
                                                        classeEstado = "aula-block-cancelada";
                                                    }
                                                    String idAula = aula.get("idAula");
                                                %>
                                                    <div class="aula-block <%= classeEstado %>">
                                                        <span class="aula-aluno"><%= aula.get("aluno") %></span>
                                                        <span class="aula-hora"><%= aula.get("horaInicio") %> - <%= aula.get("horaFim") %></span>
                                                        <div class="aula-acoes">
                                                            <% if ("Agendada".equals(estado)) { %>
                                                                <a href="processar_estado_aula.jsp?idAula=<%= idAula %>&estado=Concluída&semana=<%= offsetSemana %>" 
                                                                   class="btn-acao btn-concluir" 
                                                                   onclick="return confirm('Marcar como concluída? Esta ação é IRREVERSÍVEL!')">
                                                                    <i class="fa fa-check"></i>Concluir
                                                                </a>
                                                                <a href="processar_estado_aula.jsp?idAula=<%= idAula %>&estado=Cancelada&semana=<%= offsetSemana %>" 
                                                                   class="btn-acao btn-cancelar" 
                                                                   onclick="return confirm('Cancelar esta aula? Esta ação é IRREVERSÍVEL!')">
                                                                    <i class="fa fa-times"></i>Cancelar
                                                                </a>
                                                            <% } else if ("Concluída".equals(estado)) { %>
                                                                <span style="color:#4CAF50;font-weight:bold;font-size:0.75rem">✓ Concluída</span>
                                                            <% } else if ("Cancelada".equals(estado)) { %>
                                                                <span style="color:#f44336;font-weight:bold;font-size:0.75rem">✗ Cancelada</span>
                                                            <% } %>
                                                        </div>
                                                    </div>
                                                <% } %>
                                            </td>
                                        <% } %>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                        
                        <div class="legenda">
                            <div class="legenda-item">
                                <div class="legenda-cor cor-agendada"></div>
                                <span>Agendada</span>
                            </div>
                            <div class="legenda-item">
                                <div class="legenda-cor cor-concluida"></div>
                                <span>Concluída</span>
                            </div>
                            <div class="legenda-item">
                                <div class="legenda-cor cor-cancelada"></div>
                                <span>Cancelada</span>
                            </div>
                        </div>
            <%
                    } else {
                        out.println("<p style='color:#f44336'>Instrutor não encontrado.</p>");
                    }
                } catch (Exception e) {
                    out.println("<p style='color:#f44336'>Erro: " + e.getMessage() + "</p>");
                    e.printStackTrace();
                } finally {
                    try {
                        if (rs != null) rs.close();
                        if (pstmt != null) pstmt.close();
                        if (conn != null) conn.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            %>
        </div>
    </div>
</body>
</html>




