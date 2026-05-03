<%-- 
    Document   : processar_agendamento_DEBUG
    Created on : 23/01/2026, 20:41:11
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page import="java.text.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // ===== VALIDAÇÃO DE SESSÃO =====
    if (session.getAttribute("logado") == null || !((Boolean)session.getAttribute("logado"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String tipo = (String) session.getAttribute("tipo");
    if (!"Aluno".equals(tipo)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // ===== RECEBER PARÂMETROS =====
    String idAlunoStr = request.getParameter("idAluno");
    String idInstrutorStr = request.getParameter("idInstrutor");
    String data = request.getParameter("data");
    String hora = request.getParameter("hora");
    String duracaoStr = request.getParameter("duracao");

    // Validar se todos os parâmetros foram recebidos
    if (idAlunoStr == null || idInstrutorStr == null || data == null || hora == null || duracaoStr == null) {
        response.sendRedirect("agendar_aula.jsp?erro=parametros");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = ConexaoBD.getConnection();
        
        int idAluno = Integer.parseInt(idAlunoStr);
        int idInstrutor = Integer.parseInt(idInstrutorStr);
        int duracao = Integer.parseInt(duracaoStr);

        // ===== VALIDAÇÃO 1: Data não pode ser no passado =====
        SimpleDateFormat sdfData = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat sdfDataHora = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        
        java.util.Date dataAula = sdfData.parse(data);
        java.util.Date hoje = new java.util.Date();
        
        // Comparar só a data (ignorar hora)
        java.util.Calendar calAula = java.util.Calendar.getInstance();
        calAula.setTime(dataAula);
        calAula.set(java.util.Calendar.HOUR_OF_DAY, 0);
        calAula.set(java.util.Calendar.MINUTE, 0);
        calAula.set(java.util.Calendar.SECOND, 0);
        
        java.util.Calendar calHoje = java.util.Calendar.getInstance();
        calHoje.setTime(hoje);
        calHoje.set(java.util.Calendar.HOUR_OF_DAY, 0);
        calHoje.set(java.util.Calendar.MINUTE, 0);
        calHoje.set(java.util.Calendar.SECOND, 0);
        
        if (calAula.before(calHoje)) {
            response.sendRedirect("agendar_aula.jsp?erro=passado&data=" + data + "&hora=" + hora + "&duracao=" + duracao);
            return;
        }

        // ===== CALCULAR HORÁRIOS =====
        String dataHoraInicio = data + " " + hora + ":00";
        java.util.Date inicio = sdfDataHora.parse(dataHoraInicio);
        
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.setTime(inicio);
        cal.add(java.util.Calendar.HOUR, duracao);
        String dataHoraFim = sdfDataHora.format(cal.getTime());

        // ===== VALIDAÇÃO 2: Limite de 2h por dia =====
        pstmt = conn.prepareStatement(
            "SELECT COALESCE(SUM(TIMESTAMPDIFF(HOUR, dataHoraInicio, dataHoraFim)), 0) as totalHoras " +
            "FROM aula_conducao " +
            "WHERE idAluno = ? AND DATE(dataHoraInicio) = ? AND estado = 'Agendada'"
        );
        pstmt.setInt(1, idAluno);
        pstmt.setString(2, data);
        rs = pstmt.executeQuery();
        
        int horasJaMarcadas = 0;
        if (rs.next()) {
            horasJaMarcadas = rs.getInt("totalHoras");
        }
        rs.close();
        pstmt.close();

        if (horasJaMarcadas + duracao > 2) {
            response.sendRedirect("agendar_aula.jsp?erro=limite&data=" + data + "&hora=" + hora + "&duracao=" + duracao);
            return;
        }

        // ===== VALIDAÇÃO 3: Conflito com instrutor =====
        pstmt = conn.prepareStatement(
            "SELECT COUNT(*) as conflitos " +
            "FROM aula_conducao " +
            "WHERE idInstrutor = ? " +
            "AND estado = 'Agendada' " +
            "AND NOT (dataHoraFim <= ? OR dataHoraInicio >= ?)"
        );
        pstmt.setInt(1, idInstrutor);
        pstmt.setString(2, dataHoraInicio);
        pstmt.setString(3, dataHoraFim);
        rs = pstmt.executeQuery();
        
        int conflitos = 0;
        if (rs.next()) {
            conflitos = rs.getInt("conflitos");
        }
        rs.close();
        pstmt.close();

        if (conflitos > 0) {
            response.sendRedirect("agendar_aula.jsp?erro=conflito&data=" + data + "&hora=" + hora + "&duracao=" + duracao);
            return;
        }

        // ===== BUSCAR VEÍCULO DO INSTRUTOR =====
        pstmt = conn.prepareStatement(
            "SELECT idVeiculo FROM instrutor WHERE id = ?"
        );
        pstmt.setInt(1, idInstrutor);
        rs = pstmt.executeQuery();
        
        Integer idVeiculo = null;
        if (rs.next()) {
            idVeiculo = rs.getInt("idVeiculo");
            if (rs.wasNull()) {
                idVeiculo = null;
            }
        }
        rs.close();
        pstmt.close();

        // Se instrutor não tem veículo, usa o primeiro veículo disponível
        if (idVeiculo == null) {
            pstmt = conn.prepareStatement(
                "SELECT id FROM veiculo WHERE ativo = 1 LIMIT 1"
            );
            rs = pstmt.executeQuery();
            if (rs.next()) {
                idVeiculo = rs.getInt("id");
            }
            rs.close();
            pstmt.close();
        }

        // Se ainda não tem veículo, erro
        if (idVeiculo == null) {
            response.sendRedirect("agendar_aula.jsp?erro=semveiculo");
            return;
        }

        // ===== INSERIR AULA =====
        pstmt = conn.prepareStatement(
            "INSERT INTO aula_conducao (idAluno, idInstrutor, idVeiculo, dataHoraInicio, dataHoraFim, estado) " +
            "VALUES (?, ?, ?, ?, ?, 'Agendada')"
        );
        pstmt.setInt(1, idAluno);
        pstmt.setInt(2, idInstrutor);
        pstmt.setInt(3, idVeiculo);
        pstmt.setString(4, dataHoraInicio);
        pstmt.setString(5, dataHoraFim);
        
        int resultado = pstmt.executeUpdate();

        if (resultado > 0) {
            response.sendRedirect("minhas_aulas_aluno.jsp?sucesso=1");
        } else {
            response.sendRedirect("agendar_aula.jsp?erro=falha&data=" + data + "&hora=" + hora + "&duracao=" + duracao);
        }

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("agendar_aula.jsp?erro=exception&msg=" + e.getMessage());
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


