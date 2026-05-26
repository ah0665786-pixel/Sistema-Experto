% ====================================
% HECHOS DINAMICOS
% ====================================

% Guarda respuestas del usuario
:- dynamic respuesta/2.

% Guarda historial
:- dynamic historial/3.


% ====================================
% REGLAS PRINCIPALES
% ====================================

inicio :-
    limpiar,
    menu.


% ====================================
% MENU PRINCIPAL
% ====================================

menu :-
    nl,
    write('===================================='), nl,
    write(' ASISTENTE DE CUMPLIMIENTO RGPD '), nl,
    write('===================================='), nl,
    write('1. Evaluar empresa o sitio web'), nl,
    write('2. Ver historial'), nl,
    write('3. Salir'), nl,
    write('Seleccione una opcion: '),
    read(Opcion),
    opcion(Opcion).


% ====================================
% OPCIONES DEL MENU
% ====================================

opcion(1) :-
    evaluar.

opcion(2) :-
    ver_historial.

opcion(3) :-
    write('Saliendo del sistema...'), nl.

opcion(_) :-
    write('Opcion invalida'), nl,
    menu.


% ====================================
% LIMPIAR RESPUESTAS
% ====================================

limpiar :-
    retractall(respuesta(_, _)).


% ====================================
% HACER PREGUNTAS
% ====================================

preguntar(Pregunta) :-
    repeat,

    write(Pregunta),
    write(' (si/no): '),

    read(Respuesta),
    nl,

    (
        Respuesta = si ->
        assert(respuesta(Pregunta, si)), !

    ;

        Respuesta = no ->
        assert(respuesta(Pregunta, no)), !

    ;

        write('Respuesta invalida. Escriba si. o no.'), nl,
        fail
    ).


% ====================================
% EVALUAR EMPRESA
% ====================================

evaluar :-

    limpiar,

    nl,
    write('Ingrese el nombre de la empresa o sitio web: '),
    read(Empresa),

    preguntar('La empresa solicita consentimiento para usar datos'),
    preguntar('El sitio tiene aviso de privacidad'),
    preguntar('Los usuarios pueden eliminar sus datos'),
    preguntar('La empresa protege datos con contrasenas o cifrado'),
    preguntar('El sitio informa sobre uso de cookies'),

    diagnostico(Empresa).


% ====================================
% REGLAS DE DIAGNOSTICO
% ====================================

% Cumple completamente

diagnostico(Empresa) :-

    respuesta('La empresa solicita consentimiento para usar datos', si),
    respuesta('El sitio tiene aviso de privacidad', si),
    respuesta('Los usuarios pueden eliminar sus datos', si),
    respuesta('La empresa protege datos con contrasenas o cifrado', si),
    respuesta('El sitio informa sobre uso de cookies', si),

    assert(
        historial(
            Empresa,
            'Cumple con RGPD',
            'No necesita recomendaciones'
        )
    ),

    nl,
    write('===================================='), nl,
    write('RESULTADO: CUMPLE CON RGPD'), nl,
    write('La empresa cumple con los requisitos basicos.'), nl,
    write('===================================='), nl,

    menu.


% No cumple

diagnostico(Empresa) :-

    respuesta('La empresa solicita consentimiento para usar datos', no),

    Recomendacion =
    'Debe solicitar consentimiento para el uso de datos personales',

    assert(
        historial(
            Empresa,
            'No cumple con RGPD',
            Recomendacion
        )
    ),

    nl,
    write('===================================='), nl,
    write('RESULTADO: NO CUMPLE'), nl,
    write('Falta consentimiento del usuario.'), nl,
    write('===================================='), nl,

    recomendaciones,

    menu.


% Cumplimiento parcial

diagnostico(Empresa) :-

    generar_recomendaciones(Lista),

    assert(
        historial(
            Empresa,
            'Cumplimiento parcial',
            Lista
        )
    ),

    nl,
    write('===================================='), nl,
    write('RESULTADO: CUMPLIMIENTO PARCIAL'), nl,
    write('La empresa necesita mejorar algunas areas.'), nl,
    write('===================================='), nl,

    recomendaciones,

    menu.


% ====================================
% GENERAR RECOMENDACIONES
% ====================================

generar_recomendaciones(Lista) :-

    findall(
        Recomendacion,

        recomendacion(Recomendacion),

        Lista
    ).


% ====================================
% REGLAS DE RECOMENDACIONES
% ====================================

recomendacion('Agregar aviso de privacidad') :-
    respuesta('El sitio tiene aviso de privacidad', no).

recomendacion('Permitir eliminacion de datos') :-
    respuesta('Los usuarios pueden eliminar sus datos', no).

recomendacion('Implementar medidas de seguridad') :-
    respuesta('La empresa protege datos con contrasenas o cifrado', no).

recomendacion('Mostrar aviso de cookies') :-
    respuesta('El sitio informa sobre uso de cookies', no).


% ====================================
% MOSTRAR RECOMENDACIONES
% ====================================

recomendaciones :-

    nl,
    write('RECOMENDACIONES:'), nl,

    (
        recomendacion(R),

        write('- '),
        write(R),
        nl,

        fail
    ;

        true
    ).


% ====================================
% VER HISTORIAL
% ====================================

ver_historial :-

    nl,
    write('===================================='), nl,
    write(' HISTORIAL DE EVALUACIONES '), nl,
    write('===================================='), nl,

    (
        historial(Empresa, Resultado, Recomendaciones),

        write('Empresa/Sitio: '),
        write(Empresa),
        nl,

        write('Resultado: '),
        write(Resultado),
        nl,

        write('Recomendaciones: '),
        nl,

        write(Recomendaciones),
        nl,

        write('------------------------------------'),
        nl,

        fail
    ;

        true
    ),

    menu.