
# npTeX SyncTeX

set(nptex_include_synctex
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/synctexdir"
  )

set(nptex_link_synctex
  zlib
  )

set(nptex_ch_synctex
  synctexdir/synctex-def.ch0
  synctexdir/synctex-ep-mem.ch0
  synctexdir/synctex-mem.ch0
  synctexdir/synctex-e-mem.ch0
  synctexdir/synctex-ep-mem.ch1
  synctexdir/synctex-p-rec.ch0
  synctexdir/synctex-rec.ch0
  synctexdir/synctex-rec.ch1
  synctexdir/synctex-ep-rec.ch0
  synctexdir/synctex-e-rec.ch0
  synctexdir/synctex-p-rec.ch1
  )

set(dist_nptex_SOURCES_synctex
  synctexdir/synctex.c
  synctexdir/synctex.h
  synctexdir/synctex-common.h
  synctexdir/synctex-nptex.h
  )

set(nptex_definitions_synctex
  PRIVATE -D__SyncTeX__
  PRIVATE -DSYNCTEX_ENGINE_H=\"synctex-nptex.h\"
  )

# npTeX

set(nptex_c_h
  nptexini.c
  nptex0.c
  nptexcoerce.h
  nptexd.h
  )

set(nodist_nptex_SOURCES
  ${nptex_c_h}
  nptex-pool.c
  )

set(dist_nptex_SOURCES
  nptexdir/nptexextra.c
  nptexdir/nptexextra.h
  ${dist_nptex_SOURCES_synctex}
  )

set(nptex_prereq
  nptexd.h
  etexdir/etex_version.h
  ptexdir/ptex_version.h
  eptexdir/eptex_version.h
  uptexdir/uptex_version.h
  )

set(nptex_web_srcs
  tex.web
  etexdir/etex.ch
  etexdir/tex.ch0
  tex.ch
  tracingstacklevels.ch
  partoken.ch
  showstream.ch
  zlib-fmt.ch
  etexdir/tex.ech
  )

set(nptex_ch_srcs
  nptexdir/nptex-base.ch
  ${nptex_ch_synctex}
  eptexdir/char-warning-eptex.ch
  tex-binpool.ch
  )

set(nptex_SRCS
  ${nodist_nptex_SOURCES}
  ${dist_nptex_SOURCES}
  ${nptex_prereq}
  )

if(WIN32)
  add_library(nptex SHARED ${nptex_SRCS})
else()
  add_executable(nptex ${nptex_SRCS})
endif()

target_compile_definitions(nptex ${nptex_definitions_synctex})

target_include_directories(nptex
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}"
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/libmd5"
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
  ${nptex_include_synctex}
  )

target_link_libraries(nptex libukanji web2c_libp ptexenc libmd5 zlib web2c_lib kpathsea ${nptex_link_synctex})

web2c_convert(nptex OUTPUT ${nptex_c_h} DEPENDS nptex.p ${web2c_texmf} nptexdir/nptex.defines)

web2c_texmf_tangle(nptex OUTPUT nptex.p nptex.pool DEPENDS nptex.web nptex.ch)

web2c_tie_m(nptex.web SOURCES ${nptex_web_srcs})
web2c_tie_c(nptex.ch SOURCES nptex.web ${nptex_ch_srcs})

add_custom_command(
  OUTPUT nptex-pool.c
  DEPENDS nptex.pool nptexd.h makecpool
  COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/cmake/makecpool.py"
    "--makecpool" "$<TARGET_FILE_DIR:makecpool>/makecpool"
    nptex nptex-pool.c
  )

if(WIN32)
  add_executable(calldll_nptex "cmake/calldll.c")
  target_compile_definitions(calldll_nptex PRIVATE DLLPROC=dllnptexmain)
  target_link_libraries(calldll_nptex nptex)

  foreach(name nptex nplatex nplatex-dev)
    add_custom_command(TARGET calldll_nptex POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy
        "$<TARGET_FILE:calldll_nptex>"
        "$<TARGET_FILE_DIR:calldll_nptex>/${name}.exe"
      )
  endforeach()
endif()
