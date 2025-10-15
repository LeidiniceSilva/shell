import fileinput
import os
import subprocess
import sys
import glob

#####
### ALL else you need:
### 1st read_pr_timestep_[domain_institute_model].py
### 2nd MTDConfig_SKM_python_default_[domain_institute_model]
#####

work_dir = '/home/mda_silv/'

default_smoo_rad = 'default_smoo_rad'
default_TH       = 'default_pr_TH'
default_grid_res = 'default_grid_res'
default_prefix   = 'default_prefix'
default_minvol   = 'default_minvol'
default_smoo_tim = 'default_smoo_time'

domain           = sys.argv[1]
model            = sys.argv[2]
domain_model     = domain+'_'+model
scenario         = sys.argv[3]
Var              = sys.argv[4]#'pr'
TH               = sys.argv[5]#'5.0'
minvol           = sys.argv[6]#'1000'  
smoothing_radius = sys.argv[7]#8
smoothing_time   = sys.argv[8]#1
grid_res         = sys.argv[9]#'3'
#calendar         = sys.argv[10]#365
#Bug743           = sys.argv[11]

default_file     = work_dir+'github_projects/shell/ictp/regcm_post_v1/cordex5/hpe/mtd/'+domain+'/'+model+'/MTDConfig_files/MTDConfig_SKM_python_default_'+domain_model
pr_input_dir     = work_dir+'users/HPEs/input/'+domain+'/'+model+'/'

print(default_file)
print()
print(pr_input_dir)
print()


List_Files       = glob.glob(pr_input_dir+'*.nc')
List_Files.sort()

gatherer         = domain_model+'_'+scenario+'_'+Var+'TH%2.2i'%float(TH)+'_rsmoo'+smoothing_radius+'_tsmoo'+smoothing_time+'_minvol'+minvol
simple_gatherer  = Var+'TH%2.2i'%float(TH)+'_rsmoo'+smoothing_radius+'_tsmoo'+smoothing_time+'_minvol'+minvol
MTD_output_dir   = work_dir+'users/HPEs/output/'+domain+'/'+model+
print_put_str    = ''
print_run_str    = ''
print_sbatch_str = ''

print(gatherer)
print()
print(simple_gatherer)
print()
print(MTD_output_dir)
print()

if not os.path.isdir(MTD_output_dir): subprocess.call('mkdir -p '+MTD_output_dir,shell=True)

i_file=-1
for File in List_Files:
	i_file+=1

	if 'CMORPH' in domain_model:
		date = File[-18:-10]	
	if 'RegCM5' in domain_model:
		date = File[-18:-10]
	if 'WRF415' in domain_model:
		date = File[-18:-10]
	if 'CPRCM' in domain_model:
		date = File[-18:-10]

	if (i_file/12.) in [0.,1.,2.,3.,4.,5.,6.,7.,8.,9.,10]:

		if not i_file == 0:
			run_file.close()
		if os.path.isfile(work_dir+'github_projects/shell/ictp/regcm_post_v1/cordex5/hpe/mtd/'+domain+'/'+model+'/run_jobs/run_file_'+gatherer+'_%2.2i'%(i_file/12)+'.py'):
			subprocess.call('rm '+work_dir+'github_projects/shell/ictp/regcm_post_v1/cordex5/hpe/mtd/'+domain+'/'+model+'/run_jobs/run_file_'+gatherer+'_%2.2i'%(i_file/12)+'.py',shell=True)

		sbatch_file=open(work_dir+'github_projects/shell/ictp/regcm_post_v1/cordex5/hpe/mtd/'+domain+'/'+model+'/run_jobs/sbatch_file_'+gatherer+'_%2.2i'%(i_file/12)+'.job','w')
		run_file=open(work_dir+'github_projects/shell/ictp/regcm_post_v1/cordex5/hpe/mtd/'+domain+'/'+model+'/run_jobs/run_file_'+gatherer+'_%2.2i'%(i_file/12)+'.py','w')
		print(sbatch_file)
		print()
		print(run_file)
		print()

		run_file.write('import subprocess\nimport glob\nimport os\n')
		sbatch_file.write('#!/bin/bash\n')
		sbatch_file.write('#SBATCH -p esp # partition\n')
		sbatch_file.write('#SBATCH -N 1\n')
		sbatch_file.write('#SBATCH -t 24:00:00 # wall clock limit\n')
		sbatch_file.write('#SBATCH -J '+gatherer+'_%2.2i'%(i_file/12)+' # jobname\n')
		sbatch_file.write('#SBATCH -o outerr_story/o_'+gatherer+'_%2.2i'%(i_file/12)+'.out\n')
		sbatch_file.write('#SBATCH -e outerr_story/e_'+gatherer+'_%2.2i'%(i_file/12)+'.err\n')
		sbatch_file.write('#SBATCH --mail-type=FAIL,END\n')
		sbatch_file.write('#SBATCH --mail-user=mda_silv@ictp.it\n')
		sbatch_file.write('source /opt-ictp/ESMF/env202108\n')
		sbatch_file.write('python3 '+work_dir+'github_projects/shell/ictp/regcm_post_v1/cordex5/hpe/mtd/SESA-3/CMORPH/run_jobs/run_file_'+gatherer+'_%2.2i'%(i_file/12)+'.py\n')
		sbatch_file.close()

		print_sbatch_str+='sbatch '+work_dir+'github_projects/shell/ictp/regcm_post_v1/cordex5/hpe/mtd/SESA-3/CMORPH/run_jobs/sbatch_file_'+gatherer+'_%2.2i'%(i_file/12)+'.job\n'
		
	presuffix = gatherer+'_'+date
	New_Name  = default_file.replace('_default_'+domain_model,'_'+presuffix)

	if os.path.isfile(work_dir+'github_projects/shell/ictp/regcm_post_v1/cordex5/hpe/mtd/SESA-3/CMORPH/MTDConfig_files/'+New_Name):
		subprocess.call('rm '+work_dir+'github_projects/shell/ictp/regcm_post_v1/cordex5/hpe/mtd/SESA-3/CMORPH/MTDConfig_files/'+New_Name,shell=True)

	with open(default_file) as infile, open(New_Name, 'w') as outfile:

		for line in infile:
			line=line.replace('cmorph_SESA-3_CMORPH_1hr_20000101_lonlat.nc',File)
			line=line.replace(default_smoo_rad,smoothing_radius)
			line=line.replace(default_grid_res,grid_res)
			line=line.replace(default_TH,TH)
			line=line.replace(default_prefix,presuffix+'_')
			line=line.replace(default_minvol,minvol)
			line=line.replace(default_smoo_tim,smoothing_time)
			line=line.replace('read_pr_timestep.py',work_dir+'read_'+Var+'_timestep_'+domain_model+'.py')
			outfile.write(line)
	outfile.close()
	print(run_file)

	run_file.write('if not len(glob.glob(\''+MTD_output_dir+'mtd_'+presuffix+'.nc\')) == 1:\n subprocess.call(\'/home/mda_silv/d1/met/12.0.0/bin/mtd -single 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 -config '+New_Name+' -outdir '+MTD_output_dir+' \', shell=True)\n')

	end_print=('subprocess.call(\'/home/mda_silv/d1/met/12.0.0/bin/mtd -single 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 -config '+New_Name+' -outdir '+MTD_output_dir+' \', shell=True)\n')
              
	print_put_str+='put '+work_dir+'MTDConfig_files/'+New_Name+'\n'
    
run_file.close()
print(print_sbatch_str)
print(end_print)

