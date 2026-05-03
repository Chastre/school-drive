<%-- 
    Document   : minhas_aulas_aluno
    Created on : 19/01/2026, 11:57:39
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
    if (!"Aluno".equals(tipo)) {
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
    <title>Minhas Aulas</title>
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
        .btn { padding: 12px 25px; border-radius: 10px; font-size: 1rem; font-weight: 600; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; transition: all 0.3s; border: 2px solid rgba(255, 255, 255, 0.3); }
        .btn-primary { background: #FFC107; color: #1a3a4d; border-color: #FFC107; }
        .btn-primary:hover { background: #FFD54F; transform: translateY(-2px); }
        .btn-secondary { background: rgba(255, 255, 255, 0.1); color: white; }
        .btn-voltar { background:rgba(255,255,255,.1); color:white; padding:10px 22px; border-radius:25px; text-decoration:none; font-weight:600; border:2px solid rgba(255,255,255,.3); display:inline-flex; align-items:center; gap:7px; transition:all .3s; }
        .btn-voltar:hover { border-color:#FFC107; color:#FFC107; }
        .btn-secondary:hover { background: rgba(255, 255, 255, 0.2); border-color: #FFC107; }
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
        .aula-block { background: linear-gradient(135deg, rgba(33, 150, 243, 0.3), rgba(33, 150, 243, 0.5)); border-left: 3px solid #2196F3; padding: 10px; margin: 2px 0; border-radius: 5px; font-size: 0.9rem; }
        .aula-block-concluida { background: linear-gradient(135deg, rgba(76, 175, 80, 0.3), rgba(76, 175, 80, 0.5)); border-left-color: #4CAF50; }
        .aula-block-cancelada { background: linear-gradient(135deg, rgba(244, 67, 54, 0.3), rgba(244, 67, 54, 0.5)); border-left-color: #f44336; opacity: 0.7; }
        .aula-instrutor { font-weight: 700; color: white; display: block; margin-bottom: 5px; }
        .aula-hora { font-size: 0.85rem; color: rgba(255, 255, 255, 0.9); margin-bottom: 5px; }
        .aula-estado { display: inline-block; padding: 3px 8px; border-radius: 4px; font-size: 0.75rem; font-weight: 600; }
        .estado-agendada { background: rgba(33, 150, 243, 0.3); color: #2196F3; border: 1px solid #2196F3; }
        .estado-concluida { background: rgba(76, 175, 80, 0.3); color: #4CAF50; border: 1px solid #4CAF50; }
        .estado-cancelada { background: rgba(244, 67, 54, 0.3); color: #f44336; border: 1px solid #f44336; }
        .hoje { background: rgba(255, 193, 7, 0.1) !important; }
        .legenda { display: flex; gap: 20px; margin-top: 20px; flex-wrap: wrap; }
        .legenda-item { display: flex; align-items: center; gap: 8px; }
        .legenda-cor { width: 20px; height: 20px; border-radius: 4px; }
        .cor-agendada { background: #2196F3; }
        .cor-concluida { background: #4CAF50; }
        .cor-cancelada { background: #f44336; }
        @media(max-width: 768px) { .calendar-container { padding: 15px; } .page-header h1 { font-size: 1.5rem; } }
        .teoricas-section { margin-top:30px; }
        .teoricas-header { font-size:.78rem; text-transform:uppercase; letter-spacing:1px; color:#FFC107; font-weight:700; margin-bottom:16px; display:flex; align-items:center; gap:8px; }
        .teoricas-header::after { content:''; flex:1; height:1px; background:rgba(255,193,7,.2); }
        .teoricas-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(180px,1fr)); gap:10px; }
        .teorica-card { background:rgba(255,255,255,.05); border:1px solid rgba(255,193,7,.15); border-radius:12px; padding:14px; text-align:center; }
        .teorica-data { font-size:.82rem; font-weight:700; color:#FFC107; margin-bottom:4px; }
        .teorica-slot { font-size:.78rem; color:rgba(255,255,255,.7); margin-bottom:6px; }
        .teorica-badge { font-size:.7rem; padding:3px 10px; border-radius:8px; font-weight:700; background:rgba(40,167,69,.25); color:#a8f0b8; border:1px solid rgba(40,167,69,.4); }
        .teoricas-empty { text-align:center; padding:30px; color:rgba(255,255,255,.4); font-size:.9rem; }
        .teoricas-resumo { background:rgba(255,193,7,.08); border:1px solid rgba(255,193,7,.2); border-radius:12px; padding:14px 18px; margin-bottom:16px; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:10px; }
        .teoricas-resumo span { font-size:.9rem; color:rgba(255,255,255,.8); }
        .teoricas-resumo strong { color:#FFC107; }
        /* AULAS TEÓRICAS */
</style>
</head>
<body>
    <div class="topbar">
        <div class="container">
            <div class="user-info">
                <i class="fa fa-user-graduate"></i>
                <span><strong><%= username %></strong> (Aluno)</span>
            </div>
            <a href="logout.jsp" class="btn-sair">
                <i class="fa fa-sign-out-alt"></i>
                Sair
            </a>
        </div>
    </div>

    <div class="container">
        <a href="dashboard_aluno.jsp" class="logo-link">
            <img src="image/logo_mini.png" alt="Drive School">
        </a>

        <div class="page-header">
            <h1><i class="fa fa-calendar-week"></i>Minhas Aulas</h1>
            <div style="display:flex;gap:12px;">
                <a href="dashboard_aluno.jsp" class="btn-voltar"><i class="fa fa-arrow-left"></i>Voltar</a>
                <a href="agendar_aula.jsp" class="btn btn-primary">
                    <i class="fa fa-plus-circle"></i>
                    Agendar Aula
                </a>
            </div>
        </div>

        <%
            String sucesso = request.getParameter("sucesso");
            if ("1".equals(sucesso)) {
        %>
            <div class="alert-success">
                <i class="fa fa-check-circle"></i>
                Aula agendada com sucesso!
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
                    
                    // Buscar idAluno diretamente da tabela t_utilizador
                    String sqlAluno = "SELECT idAluno FROM t_utilizador WHERE username = ?";
                    pstmt = conn.prepareStatement(sqlAluno);
                    pstmt.setString(1, username);
                    rs = pstmt.executeQuery();
                    
                    Integer idAluno = null;
                    if (rs.next()) {
                        idAluno = rs.getInt("idAluno");
                    }
                    rs.close();
                    pstmt.close();
                    
                    if (idAluno != null) {
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
                        
                        String sqlAulas = "SELECT ac.*, i.nome as nomeInstrutor, " +
                                        "DATE(ac.dataHoraInicio) as dataAula, " +
                                        "TIME_FORMAT(ac.dataHoraInicio, '%H:%i') as horaInicio, " +
                                        "TIME_FORMAT(ac.dataHoraFim, '%H:%i') as horaFim, " +
                                        "HOUR(ac.dataHoraInicio) as horaSlot " +
                                        "FROM aula_conducao ac " +
                                        "JOIN instrutor i ON ac.idInstrutor = i.id " +
                                        "WHERE ac.idAluno = ? AND DATE(ac.dataHoraInicio) BETWEEN ? AND ? " +
                                        "ORDER BY ac.dataHoraInicio";
                        
                        pstmt = conn.prepareStatement(sqlAulas);
                        pstmt.setInt(1, idAluno);
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
                            aula.put("instrutor", rs.getString("nomeInstrutor"));
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
                                                    String classeEstadoBadge = "estado-agendada";
                                                    
                                                    if ("Concluída".equals(estado)) {
                                                        classeEstado = "aula-block-concluida";
                                                        classeEstadoBadge = "estado-concluida";
                                                    } else if ("Cancelada".equals(estado)) {
                                                        classeEstado = "aula-block-cancelada";
                                                        classeEstadoBadge = "estado-cancelada";
                                                    }
                                                %>
                                                    <div class="aula-block <%= classeEstado %>">
                                                        <span class="aula-instrutor">👨‍🏫 <%= aula.get("instrutor") %></span>
                                                        <span class="aula-hora">🕐 <%= aula.get("horaInicio") %> - <%= aula.get("horaFim") %></span>
                                                        <span class="aula-estado <%= classeEstadoBadge %>"><%= estado %></span>
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
                        out.println("<p style='color:#f44336'>Aluno não encontrado.</p>");
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

        <!-- AULAS TEÓRICAS -->
        <div class="teoricas-section">
            <%
            Connection connT = null;
            try {
                connT = ConexaoBD.getConnection();
                PreparedStatement psT = connT.prepareStatement(
                    "SELECT at2.data, at2.hora, at2.observacoes " +
                    "FROM aula_teorica at2 " +
                    "JOIN aluno a ON a.id = at2.idAluno " +
                    "JOIN t_utilizador u ON u.idAluno = a.id " +
                    "WHERE u.username = ? AND at2.estado = 'realizada' " +
                    "ORDER BY at2.data DESC, at2.hora DESC");
                psT.setString(1, username);
                ResultSet rsT = psT.executeQuery();
                java.util.List<String[]> aulasT = new java.util.ArrayList<>();
                while(rsT.next()) {
                    String horaSlot = rsT.getString("hora");
                    String horaFimSlot = "";
                    if (horaSlot != null) {
                        int hh = Integer.parseInt(horaSlot.substring(0,2)) + 1;
                        horaFimSlot = String.format("%02d:00", hh);
                        horaSlot = horaSlot.substring(0,5);
                    }
                    aulasT.add(new String[]{ rsT.getString("data"), horaSlot, horaFimSlot, rsT.getString("observacoes") });
                }
                rsT.close(); psT.close();
                int totalT = aulasT.size();
                int faltamT = Math.max(0, 20 - totalT);
            %>
            <div class="calendar-container">
                <div class="teoricas-header"><i class="fa fa-chalkboard"></i> Aulas Teóricas (Código)</div>
                <div class="teoricas-resumo">
                    <span>Total de aulas realizadas: <strong><%= totalT %>/20</strong></span>
                    <% if (faltamT > 0) { %>
                    <span>Faltam <strong><%= faltamT %> aulas</strong> para aceder à condução</span>
                    <% } else { %>
                    <span style="color:#a8f0b8;font-weight:700;"><i class="fa fa-check-circle" style="margin-right:6px;"></i>Aulas teóricas completas!</span>
                    <% } %>
                </div>
                <% if (aulasT.isEmpty()) { %>
                <div class="teoricas-empty">
                    <i class="fa fa-book fa-2x" style="display:block;margin-bottom:10px;opacity:.3;"></i>
                    Ainda não tens aulas teóricas registadas.
                </div>
                <% } else { %>
                <div class="teoricas-grid">
                    <% for (String[] at : aulasT) { %>
                    <div class="teorica-card">
                        <div class="teorica-data"><i class="fa fa-calendar" style="margin-right:5px;"></i><%= at[0] %></div>
                        <div class="teorica-slot"><%= at[1] %> — <%= at[2] %></div>
                        <span class="teorica-badge"><i class="fa fa-check" style="margin-right:4px;"></i>Realizada</span>
                        <% if (at[3] != null && !at[3].isEmpty()) { %>
                        <div style="font-size:.72rem;color:rgba(255,255,255,.45);margin-top:6px;"><%= at[3] %></div>
                        <% } %>
                    </div>
                    <% } %>
                </div>
                <% } %>
            </div>
            <%
            } catch(Exception eT){ eT.printStackTrace(); }
            finally { try{ if(connT!=null) connT.close(); }catch(Exception eT){} }
            %>
        </div>
    </div>
</body>
</html>

