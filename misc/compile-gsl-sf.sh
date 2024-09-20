#!/bin/bash

LLVM_PROJECT_PATH=/atom
GSL_PREFIX=/atom/gslbuild

MODULE_PATH=${LLVM_PROJECT_PATH}/lib/libPassModule.so
HANDLER_PATH=${LLVM_PROJECT_PATH}/build/handlers.o
FPUTIL_PATH=${LLVM_PROJECT_PATH}/build/fpUtil.o


libgslspecfunc_SOURCE="airy.c airy_der.c airy_zero.c atanint.c bessel.c bessel_I0.c bessel_I1.c bessel_In.c bessel_Inu.c bessel_J0.c bessel_J1.c bessel_Jn.c bessel_Jnu.c bessel_K0.c bessel_K1.c bessel_Kn.c bessel_Knu.c bessel_Y0.c bessel_Y1.c bessel_Yn.c bessel_Ynu.c bessel_amp_phase.c bessel_i.c bessel_j.c bessel_k.c bessel_olver.c bessel_temme.c bessel_y.c bessel_zero.c bessel_sequence.c beta.c beta_inc.c clausen.c coulomb.c coupling.c coulomb_bound.c dawson.c debye.c dilog.c elementary.c ellint.c elljac.c erfc.c exp.c expint.c expint3.c fermi_dirac.c gegenbauer.c gamma.c gamma_inc.c hermite.c hyperg_0F1.c hyperg_2F0.c hyperg_1F1.c hyperg_2F1.c hyperg_U.c hyperg.c laguerre.c lambert.c legendre_H3d.c legendre_P.c legendre_Qn.c legendre_con.c legendre_poly.c log.c mathieu_angfunc.c mathieu_charv.c mathieu_coeff.c mathieu_radfunc.c mathieu_workspace.c poch.c pow_int.c psi.c result.c shint.c sincos_pi.c sinint.c synchrotron.c transport.c trig.c zeta.c"

clean_the_data_dir() {
    rm -rf ./data/
}

compile_one_with_llvm_module() {
    echo "Compileing $1 ..."

    ir_file=${1%.c}.ll
    ir_instructed_file=${1%.c}_i.ll
    pic_file=.libs/${1%.c}.o
    nonpic_file=${1%.c}.o

    # echo $ir_file
    # echo $ir_instructed_file
    # echo $pic_file
    # echo $nonpic_file

    set -x
    clang-3.9 -DHAVE_CONFIG_H -I. -I.. -S -emit-llvm -g -o $ir_file $1
    opt-3.9 -S -load $MODULE_PATH -funcpass -o $ir_instructed_file $ir_file
    clang-3.9 -O2 -DHAVE_CONFIG_H -fPIC -DPIC -c -o $pic_file $ir_instructed_file
    clang-3.9 -O2 -DHAVE_CONFIG_H -c -o $nonpic_file $ir_instructed_file
    set +x
}

compile_all_with_llvm_module() {
    # compile_with_llvm_module sincos_pi.c
    for src in $libgslspecfunc_SOURCE; do
        compile_one_with_llvm_module $src
    done
}

compile_all_directly() {
    make -j4
}

create_libtool_file() {
    cat << EOF > handlers.lo
# handlers.lo - a libtool object file
# Generated by libtool (GNU libtool) 2.4.2
#
# Please DO NOT delete this file!
# It is necessary for linking the library

# Name of the PIC object.
pic_object='${HANDLER_PATH}'

# Name of the non-PIC object.
non_pic_object='${HANDLER_PATH}'
EOF

    cat << EOF > fputil.lo
# fputil.lo - a libtool object file
# Generated by libtool (GNU libtool) 2.4.2
#
# Please DO NOT delete this file!
# It is necessary for linking the library

# Name of the PIC object.
pic_object='${FPUTIL_PATH}'

# Name of the non-PIC object.
non_pic_object='${FPUTIL_PATH}'
EOF
}

linking_libgslspecfunc() {
    /bin/bash ../libtool  --tag=CC   --mode=link clang-3.9  -g -O2   -o libgslspecfunc.la  airy.lo airy_der.lo airy_zero.lo atanint.lo bessel.lo bessel_I0.lo bessel_I1.lo bessel_In.lo bessel_Inu.lo bessel_J0.lo bessel_J1.lo bessel_Jn.lo bessel_Jnu.lo bessel_K0.lo bessel_K1.lo bessel_Kn.lo bessel_Knu.lo bessel_Y0.lo bessel_Y1.lo bessel_Yn.lo bessel_Ynu.lo bessel_amp_phase.lo bessel_i.lo bessel_j.lo bessel_k.lo bessel_olver.lo bessel_temme.lo bessel_y.lo bessel_zero.lo bessel_sequence.lo beta.lo beta_inc.lo clausen.lo coulomb.lo coupling.lo coulomb_bound.lo dawson.lo debye.lo dilog.lo elementary.lo ellint.lo elljac.lo erfc.lo exp.lo expint.lo expint3.lo fermi_dirac.lo gegenbauer.lo gamma.lo gamma_inc.lo hermite.lo hyperg_0F1.lo hyperg_2F0.lo hyperg_1F1.lo hyperg_2F1.lo hyperg_U.lo hyperg.lo laguerre.lo lambert.lo legendre_H3d.lo legendre_P.lo legendre_Qn.lo legendre_con.lo legendre_poly.lo log.lo mathieu_angfunc.lo mathieu_charv.lo mathieu_coeff.lo mathieu_radfunc.lo mathieu_workspace.lo poch.lo pow_int.lo psi.lo result.lo shint.lo sincos_pi.lo sinint.lo synchrotron.lo transport.lo trig.lo zeta.lo handlers.lo fputil.lo -lm -lstdc++
}

linking_libgsl_and_install() {
    cd ..
    /bin/bash ./libtool  --tag=CC   --mode=link clang-3.9  -g -O2  -version-info 24:0:1  -o libgsl.la -rpath ${GSL_PREFIX}/lib version.lo  block/libgslblock.la blas/libgslblas.la bspline/libgslbspline.la complex/libgslcomplex.la cheb/libgslcheb.la dht/libgsldht.la diff/libgsldiff.la deriv/libgslderiv.la eigen/libgsleigen.la err/libgslerr.la fft/libgslfft.la filter/libgslfilter.la fit/libgslfit.la histogram/libgslhistogram.la ieee-utils/libgslieeeutils.la integration/libgslintegration.la interpolation/libgslinterpolation.la linalg/libgsllinalg.la matrix/libgslmatrix.la min/libgslmin.la monte/libgslmonte.la multifit/libgslmultifit.la multifit_nlinear/libgslmultifit_nlinear.la multilarge/libgslmultilarge.la multilarge_nlinear/libgslmultilarge_nlinear.la multimin/libgslmultimin.la multiroots/libgslmultiroots.la ntuple/libgslntuple.la ode-initval/libgslodeiv.la ode-initval2/libgslodeiv2.la permutation/libgslpermutation.la combination/libgslcombination.la multiset/libgslmultiset.la poly/libgslpoly.la qrng/libgslqrng.la randist/libgslrandist.la rng/libgslrng.la roots/libgslroots.la siman/libgslsiman.la sort/libgslsort.la specfunc/libgslspecfunc.la movstat/libgslmovstat.la rstat/libgslrstat.la statistics/libgslstatistics.la sum/libgslsum.la sys/libgslsys.la test/libgsltest.la utils/libutils.la vector/libgslvector.la cdf/libgslcdf.la wavelet/libgslwavelet.la spmatrix/libgslspmatrix.la spblas/libgslspblas.la splinalg/libgslsplinalg.la -lm
    /bin/bash ./libtool  --tag=CC   --mode=link clang-3.9  -g -O2   -o gsl-randist gsl-randist.o libgsl.la cblas/libgslcblas.la -lm -lstdc++
    /bin/bash ./libtool  --tag=CC   --mode=link clang-3.9  -g -O2   -o gsl-histogram gsl-histogram.o libgsl.la cblas/libgslcblas.la -lm -lstdc++
    make install
}

main() {
    set -e
    if [ "$1" == "link" ]; then
        create_libtool_file
        set -x
        linking_libgslspecfunc
        linking_libgsl_and_install
    else
        clean_the_data_dir
        compile_all_directly
        compile_all_with_llvm_module
        create_libtool_file
        set -x
        linking_libgslspecfunc
        linking_libgsl_and_install
    fi
}

main $1
