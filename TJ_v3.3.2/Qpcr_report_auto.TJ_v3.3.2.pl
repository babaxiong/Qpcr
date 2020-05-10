#!/user/bin/perl
use strict;

use File::Basename;
use FindBin qw($Bin);
use Encode;
use Win32::OLE;
use Win32::OLE::Variant;

my $shell  = Win32::OLE->new("shell.Application");
my $message= "选择Sims Excel文件所在目录";
my $folder = $shell->BrowseForFolder( 0, $message, 0 );
my $path   = $folder->Self->Path;
$path =~ s/\\/\//g;

my %front;
my %logo;
my %pdcd;
my @hos;

open PD,"$path/data/Product_Coding.txt" or die $!;
while (<PD>)
{
	chomp; next if /^#/;
	my @line=split(/\t/,$_);
	my ($pdid, $pdna, $pdhos, $pdfront, $pdy) = @line[0, 1, 2, 3, 4];
	my $id_hos = "$pdid$pdhos";
	push @{$pdcd{$id_hos}}, ($pdna, $pdfront, $pdy);
	push @hos, $line[2];

}
close PD;	

my $excel = Win32::OLE->new('Excel.Application') or die $!;
#$excel->{Visible} = 1;  # 是否开启Excel预览
#$excel->{DisplayAlerts} = 3;
#open OT,">$path/t.txt" or die $!;


my %res;
for my $xls_result(glob "'$path/2019ncov_result.xls'")
 {
	my $workbook   = $excel->Workbooks->Open($xls_result);
	my $worksheet  = $workbook->Worksheets("result"); 
	my $maxrow = $worksheet->{UsedRange}->{Rows}->{Count};
	my $maxcol = $worksheet->{UsedRange}->{Columns}->{Count};
	for my $row(1..$maxrow)
	{
		my @Res;
		for my $col(1..$maxcol)
		{
			my $t=$worksheet->Cells($row,$col)->{Value}||"-";
			push @Res,$t;
			# print $t,"\n";
		}
		$res{$Res[0]}=$Res[1];
	}
	$workbook->Close();
	$excel->Close();
}
 for  my $key(keys %pdcd)
 {	my $info = $pdcd{$key};
	print "$key => @$info\n";
 }


for my $xls(glob "'$path/样本信息.xls*'")
{
	my $book   = $excel->Workbooks->Open($xls);
	my $sheet  = $book->Worksheets("样例维度信息"); 
	unless($sheet) { print STDERR "$xls 不包含样品信息表格，不做处理！"; next; }
	my $maxrow = $sheet->{UsedRange}->{Rows}->{Count};
	my $maxcol = $sheet->{UsedRange}->{Columns}->{Count};
	for my $row(1..$maxrow)
	{
		my @tmp;
		for my $col(1..$maxcol)
		{
			my $t=$sheet->Cells($row,$col)->{Value}||"-";
			if($t=~/^#/){
				last;
			}
			#push @tmp,$sheet->Cells($row,$col)->{Value};
			push @tmp,$t;
		}
		if(@tmp && $tmp[5] =~ /\d{7}/){
			&get_report(\@tmp);
		}
	}
	$book->Close();
	$excel->Close();
}

#excel->Quit();

sub get_report{
	my ($cinfo)=@_;
=cut
my ($sid,$sptype,$version,$spvolume,
		$name,$sex,$age,
		$manifestation,$origin_id,
		$wbc,$ly,$neu,$crp,$pct,$culture,$identify,$microscopy,
		$diagnosis,$pathogen,$drug,
		$hospital,$department,$doctor,$collect_date,$recept_date,
		$hosnum,$bednum)=@{$cinfo};#4+3+2+8+3+5+2=27
=cut
		my ($sid,$sptype,$version,$spvolume,
		$name,$sex,$age,
		$manifestation,$origin_id,
		$wbc,$ly,$neu,$crp,$pct,$culture,$identify,$microscopy,
		$diagnosis,$pathogen,$drug,
		$hospital,$department,$doctor,$collect_date,$recept_date,
		$hosnum,$bednum)=@{$cinfo}[5,7,27,76,
		10,11,12,
		24,6,
		77,78,79,80..84,
		60,85,86,
		2,30,4,8,9,
		31,32];
	my $hosid = $hospital;
	unless (grep /^$hospital$/, @hos){$hosid = "华大内部";}
	my $id_hos = "$version$hosid";
	my ($front, $log, $pdna) = ($pdcd{$id_hos}[1], $pdcd{$id_hos}[2], $pdcd{$id_hos}[0]);
	print "$id_hos,$front, $log, $pdna\n";
	my ($sec,$min,$hour,$day,$mon,$year,$wday,$yday,$isdst)=localtime(time());
    $mon +=1; 
    $year +=1900;

    my $date=sprintf("%04d-%02d-%02d %02d:%02d",$year,$mon,$day,$hour,$min);
    my $date1=sprintf("%04d%02d%02d",$year,$mon,$day);

	my %num=('DX1757', '63', 'DX1758', '65', 'DX1759', '62', 'DX1760', '64', 'DX1763', '60', 'DX1761', '61', 'DX1762', '66', 'DX1749', '59', 'DX1783', '74', 'DX1784', '75', 'DX1796', '76' , 'SD0221', '73', 'DX1867', '91', 'DX1868', '92');
	#my %num=('DX1757', '63', 'DX1758', '65', 'DX1759', '62', 'DX1760', '64', 'DX1763', '60', 'DX1761', '61', 'DX1762', '66', 'DX1749', '59' );
	open OUT,">$path/${sid}_${version}_正式报告_${name}_$date1.tex" or die $!;
	
	my $content_1; my $content_QM; my %content_s; my %content_r;
	$content_1 ="
	\\documentclass[UTF8]{ctexart}
		%-------------------------------------------------------------导言-------------------------
		\\usepackage[T1]{fontenc} %设置text格式下划线
		\\usepackage{lmodern} %设置text格式下划线
		\\usepackage{geometry}
		\\usepackage{multirow}
		\\usepackage{float}%浮动包
		\\usepackage{colortbl}%设置表格行高
		\\definecolor{lightgray}{RGB}{245,245,245}
		\\usepackage{makecell} %设置表格线
		\\usepackage{booktabs} %表格线粗细
		\\usepackage{fancyhdr}%插入页眉页脚页码包
		\\usepackage{graphicx} % 图形宏包
		\\usepackage{colortbl} %表格颜色包
		\\usepackage{setspace}%使用间距宏包
		\\usepackage{CJK,CJKnumb} %设置字体
		\\usepackage{array}%表格固定列宽内容居中
		%\\usepackage{natbib}
		%\\usepackage[superscript]{cite} % 文献上标
		\\usepackage[super,square,comma,sort&compress]{natbib}
		\\usepackage[normalem]{ulem}%添加下划线
		\\usepackage{lastpage}%获得总页数
		\\usepackage{enumerate} %列表
		\\usepackage{enumitem} %设置列表间隔
		\\setlist[enumerate,1]{label=\\arabic*、,leftmargin=7mm,labelsep=1.5mm,topsep=0mm,itemsep=-0.8mm}
		%添加水印
		\\usepackage{tikz}
		\\usepackage{xcolor}
		\\usepackage{eso-pic}
		%添加水印
		\\usepackage{longtable} %表格分页
		\\usepackage{overpic} %封面添加患者信息

		%------------------------------------------------------结束-------------------------------
	%水印
	\\newcommand\\BackgroundPicture{
		 \\put(0,0){
			\\parbox[b][\\paperheight]{\\paperwidth}{
				\\vfill
				      \\centering
					  \\begin{tikzpicture}[remember picture,overlay]
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at (current page.center) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=5cm,yshift=0cm]current page.west) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=-5cm,yshift=0cm]current page.east) {\\textcolor{gray!80!cyan!30}{PMseq}};

					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=0cm,yshift=-7cm]current page.north) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=-5cm,yshift=-7cm]current page.north east) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=5cm,yshift=-7cm]current page.north west) {\\textcolor{gray!80!cyan!30}{PMseq}};

					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=0cm,yshift=7cm]current page.south) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=5cm,yshift=7cm]current page.south west) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=-5cm,yshift=7cm]current page.south east) {\\textcolor{gray!80!cyan!30}{PMseq}};

			\\end{tikzpicture}
			\\vfill
			}
		}
	}
%水印
		\\definecolor{mygray}{gray}{.9}
		%\\newCJKfontfamily\msyh{微软雅黑}
		%\\setCJKfamilyfont{yh}{Microsoft YaHei}
		\\definecolor{myblue}{RGB}{0,74,143}


		\\newcommand{\\song}{\\CJKfamily{song}}    % 宋体
		\\newcommand{\\fs}{\\CJKfamily{fs}}             % 仿宋体
		\\newcommand{\\kai}{\\CJKfamily{kai}}          % 楷体
		\\newcommand{\\hei}{\\CJKfamily{hei}}         % 黑体
		\\newcommand{\\li}{\\CJKfamily{li}}               % 隶书

		%-----------------------------------------------结束-------------------------
		\\geometry{a4paper,centering,scale=0.8}
		\\pagestyle{fancy} %插入页眉页脚
		%\\graphicspath{{$Bin/}}
		\\graphicspath{{C:/CTEX/Pictures/}}

		%-------------------------------------------------页眉插入图片-------------
		\\newsavebox{\\headpic}
		\\sbox{\\headpic}{\\includegraphics[height=2cm]{$log.jpg}} %设置页眉logo页眉
		\\fancyhead[L]{\\usebox{\\headpic}}
		\\fancyhead[C]{\\zihao{-5}姓名：$name \\hspace{1cm}  采样日期：$collect_date  \\hspace{1cm}  样本编号：$sid}
		%--------------------------------------------------结束---------------------

		%----------------------------------------------设置页眉页脚格式------------
		
		\\rhead{\\zihao{-5} \\uline{\\hspace{14cm}DX-PMP-B$num{${version}} V1.1} \\vspace{0.1ex}   }
		 \\lfoot{\\zihao{-5} 客服电话：400-605-6655  \\hspace{0.8cm} 网址:www.bgidx.cn}
		\\cfoot{}%有该命令，页脚中间不出现页码
		%\\rfoot{\\thepage}
		\\rfoot{\\thepage \\ / \\pageref{LastPage}}
		\\renewcommand{\\headrulewidth}{0.2pt}%改为0pt即可去掉页脚上面的横线   
		\\renewcommand{\\footrulewidth}{0.2pt}
		%-------------------------------------------------结束--------------------
		\\setlength{\\extrarowheight}{4mm} %表格行高
		%\\setlength{\\parindent}{0pt}%段首不缩进
		%------------------------------------------开始正文--------------------------
		\\begin{document}
		\\bibliographystyle{unsrt} % 按文献在正文中引用的顺序排序
		\\AddToShipoutPicture{\\BackgroundPicture} %水印		
		%-----------------------------------------首页插入图片----------------------
		\\newgeometry{left=-0.8cm,bottom=0cm,right=0.8cm,top=0cm}%更改单个页面页边距 
		\\setcounter{page}{0} %页码1从第二页开始
		\\thispagestyle{empty} %首页不显示页眉页脚

		%封面添加患者信息
		\\begin{overpic}[width=\\textwidth,height=\\textheight,keepaspectratio]{$front.png}
		\\put(15,21){\\begin{tabular}{cp{270 pt}<{\\centering}}%19
		\\textcolor{myblue}{\\zihao{4}\\bfseries \\makebox[3.5em][s]{姓名}} & \\textcolor{myblue}{\\zihao{4}\\bfseries $name}\\\\
		\\arrayrulecolor{myblue}\\cline{2-2}
		\\textcolor{myblue}{\\zihao{4}\\bfseries 样本编号} & \\textcolor{myblue}{\\zihao{4}\\bfseries $sid}\\\\
		\\cline{2-2}
		\\textcolor{myblue}{\\zihao{4}\\bfseries 样本类型} & \\textcolor{myblue}{\\zihao{4}\\bfseries $sptype}\\\\
		\\cline{2-2}
		\\textcolor{myblue}{\\zihao{4}\\bfseries 检测项目} & \\textcolor{myblue}{\\zihao{4}\\bfseries $pdna}\\\\
		\\cline{2-2}
		\\textcolor{myblue}{\\zihao{4}\\bfseries 送检单位} & \\textcolor{myblue}{\\zihao{4}\\bfseries $hospital}\\\\
		
		\\cline{2-2}
		\\end{tabular}}
		\\end{overpic}		
		
		
		\\restoregeometry %恢复到原来的页边距
		%------------------------------------------------------结束-----------------------------
		%\\clearpage
		\\newpage
		\\topskip 1.5cm
		%\\vspace{6mm}%页眉横线与正文间的垂直间距

		\\noindent %顶格，不缩进
		{\\hei\\zihao{4}\\bfseries 基本信息} %如何设置使得距离页眉的距离跟检测结果一样？
		%-------------------------------------------------------开始表格-----------------------------------------------------
		\\begin{table}[H]
		%\\small% 表格内容大小
		\\zihao{-4}{\\bfseries
		%\\centering
		%\\begin{tabular}{|lll|}
		\\renewcommand\\arraystretch{0.85} %设置表格行高
		\\begin{tabular}{|p{0.33\\textwidth}|p{0.33\\textwidth}|p{0.33\\textwidth}|} %设置表格宽度
		\\hline
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{受检者信息} \\\\%竖线的作用？
		\\hline
		姓名：$name & 性别：$sex & 年龄： $age \\\\
		\\hline
		住院号：$hosnum & 床号：$bednum & 原样本编号： $origin_id  \\\\
		\\hline
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{临床信息} \\\\
		\\hline
		\\multicolumn{3}{|p{\\textwidth}|}{ 临床表现：$manifestation} \\\\
		\\hline
		\\multicolumn{3}{|p{\\textwidth}|}{临床检测} \\\\
		\\hline
		\\end{tabular}
		\\begin{tabular}{|p{0.243\\textwidth}|p{0.24\\textwidth}|p{0.24\\textwidth}|p{0.24\\textwidth}|} %设置表格宽度？？？？？？？
		血WBC：$wbc & 脑脊液WBC：$ly & 胸腹水WBC：$neu & CRP：$crp \\\\
		\\hline
		PCT：$pct & 培养结果：$culture & 鉴定结果：$identify & 镜检结果：$microscopy \\\\
		\\hline
		
		\\multicolumn{4}{|p{\\textwidth}|}{临床诊断：$diagnosis} \\\\
		\\hline
		\\multicolumn{4}{|p{\\textwidth}|}{重点关注病原：$pathogen} \\\\
		\\hline
		\\multicolumn{4}{|p{\\textwidth}|}{抗感染用药：$drug} \\\\
		\\hline
		\\rowcolor{mygray}\\multicolumn{4}{|c|}{样本信息} \\\\
		\\end{tabular}
		\\begin{tabular}{|p{0.33\\textwidth}|p{0.33\\textwidth}|p{0.33\\textwidth}|} %设置表格宽度
		\\hline
		送检单位：$hospital & 送检科室：$department & 送检医师：$doctor  \\\\
		\\hline
		采样日期：$collect_date & 收样日期：$recept_date & 报告日期：$date \\\\
		\\hline
		样本编号：$sid & 样本类型：$sptype &  样本体积：$spvolume  \\\\
		%\\Xhline{1pt}
	    \\hline
		\\end{tabular}
		";
$content_s{'DX1749'}="\\begin{tabular}{|p{0.5\\textwidth}<{\\centering}|p{0.515\\textwidth}<{\\centering}|} %设置表格宽度
		\\rowcolor{mygray}\\multicolumn{2}{|c|}{检测结果} \\\\
		\\hline
		检测基因 & 检测结果 \\\\
		\\hline
		tcdA & \\\\
		\\hline
		tcdB & \\\\
		\\hline
		\\end{tabular}}
		\\begin{tabular}{|p{1.04\\textwidth}|} %设置表格宽度？？？？？？？
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} 检测结果说明：}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad艰难梭菌包括产毒株与非产毒株，只有产毒株致病，主要毒力因子为艰难梭菌肠毒素A（tcdA）和细胞毒素B（tcdB）。目前从临床上所得的艰难梭菌根据毒素基因型分为3种：A-B-，A-B+，A+B+型。A-B-型菌株不含有毒力基因称为非产毒株。A-B+，A+B+型菌株含有毒素基因统称为产毒株。 
		
		\\qquad本结果中,tcdA基因检出阳性/阴性，tcdB基因检出阳性/阴性，说明该样本中艰难梭菌基因型为A-B-/A-B+/A+B+基因型，菌株为非产毒株/产毒株。\\\\
		\\hline
		\\end{tabular}
		\\end{table}
		\\newpage
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} 说明：}
		\\end{spacing}
		\\begin{enumerate}
		\\item 本检测采用荧光PCR技术，低于检测限不能保证可以检出。
		
		\\item 以上结论均为实验室检测数据，仅供临床参考，不能作为最终诊断结果。
		
		\\item 此报告结果仅对本次送检样本负责，报告相关解释须咨询临床医生。
		\\end{enumerate}
		\\vspace{10ex} % 增加空行

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries 检测者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries 审核者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries 报告日期：$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} 附录}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} 参考文献}
		\\end{spacing}";
$content_s{'DX1763'}="\\begin{tabular}{|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|} %设置表格宽度
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{检测结果} \\\\
		\\hline
		中文名 & 拉丁文名 & 检测结果 \\\\
		\\hline
		肠道病毒 & Enterovirus & \\\\
		\\hline
		\\end{tabular}}
		\\begin{tabular}{|p{1.04\\textwidth}|} %设置表格宽度？？？？？？？
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} 致病性说明：}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad手足口病是由肠道病毒引起的传染病，多发生于5岁以下儿童，可引起手、足、口腔等部位的疱疹，少数患儿可引起心肌炎、肺水肿、无菌性脑膜脑炎等并发症。若病情发展快，则可引起重症患儿死亡。引发手足口病的肠道病毒有20多种（型），柯萨奇病毒A组的16、4、5、9、10型，B组的2、5型，以及肠道病毒71型，均为手足口病较常见的病原体，其中以柯萨奇病毒A16型（Cox A16）和肠道病毒71型（EV 71）最为常见\$^{[1-3]}\$ 。 \\\\ 
		\\hline
		\\end{tabular}
		\\end{table}
		\\newpage
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} 说明：}
		\\end{spacing}
		\\begin{enumerate}
		\\item 本检测采用荧光PCR技术，低于检测限不能保证可以检出。
		
		\\item 以上结论均为实验室检测数据，仅供临床参考，不能作为最终诊断结果。
		
		\\item 此报告结果仅对本次送检样本负责，报告相关解释须咨询临床医生。
		\\end{enumerate}
		\\vspace{10ex} % 增加空行

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries 检测者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries 审核者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries 报告日期：$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} 附录}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} 参考文献}
		\\end{spacing}";
$content_s{'DX1758'}="\\begin{tabular}{|p{0.243\\textwidth}|p{0.24\\textwidth}|p{0.24\\textwidth}|p{0.24\\textwidth}|}
		\\rowcolor{mygray}\\multicolumn{4}{|c|}{检测结果} \\\\
		\\hline
		耐药基因 & 对应酶 & 耐药谱 & 检测结果 \\\\
		\\hline
		CTX-M1 & β-内酰胺酶 & 可导致阿莫西林、哌拉西林、头孢呋辛、头孢噻肟、先锋霉素类药物抗性，对氨曲南也有抗性 & \\\\
		\\hline
		\\end{tabular}}
		\\end{table}
		\\newpage
		\\begin{table}[H]
		\\zihao{-4}{\\bfseries
		\\renewcommand\\arraystretch{0.95} %设置表格行高
		\\begin{tabular}{|p{0.243\\textwidth}|p{0.24\\textwidth}|p{0.24\\textwidth}|p{0.24\\textwidth}|}
		\\hline
		KPC & 碳青霉烯酶 & 可导致亚胺培南、厄他培南、哌拉西林、头孢曲松钠、头孢吡肟、氨曲南、氨苄西林、头孢噻肟、头孢他啶、美罗培南等抗性 & \\\\
		\\hline
		IMP & 金属β-内酰胺酶 & 可导致氨苄西林、替卡西林、头孢唑啉、头孢他啶、亚胺培南、美罗培南等碳青霉烯类，头孢菌素类药物抗性 & \\\\
		\\hline
		VIM & 金属β-内酰胺酶 & 可导致头孢西丁、头孢曲松钠、头孢唑啉、头孢他啶、亚胺培南、美罗培南等碳青霉烯类，头孢菌素类药物抗性 & \\\\
		\\hline
		NDM & 金属β-内酰胺酶 & 可导致头孢噻肟、头孢他啶、头孢曲松钠、美罗培南、多利培南、亚胺培南等抗性 & \\\\
		\\hline
		SIM & 金属β-内酰胺酶 & 可导致头孢菌素类、碳青霉烯类药物抗性 & \\\\
		\\hline
		DIM & 金属β-内酰胺酶 & 可导致头孢西丁、阿莫西林、替卡西林、哌拉西林、头孢噻肟、亚胺培南等抗性 & \\\\
		\\hline
		\\end{tabular}}
		\\begin{tabular}{|p{1.04\\textwidth}|} %设置表格宽度？？？？？？？
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} 检测结果说明：}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad本试剂盒适用于体外定性检测导致细菌耐药相关蛋白酶基因，包括表达啶型超广谱β-内酰胺酶的CTX-M1型别基因，引起碳青霉烯类耐药碳青霉烯酶两类基因，即大多位于质粒上的碳青霉烯酶基因的A类（KPC）、B类（IMP,VIM,NDM,SIM,DIM）共7项耐药相关基因，为细菌耐药患者的诊治提供辅助手段。 \\\\
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} 结论：}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad本次检测中，细菌耐药检测结果为阳性，检出耐药基因CTX-M1/KPC/ IMP/VIM/NDM/SIM/DIM ，可导致药物抗性见检测结果耐药谱。本次检测中，细菌耐药检测结果为阴性，未检出本产品检测范围内的耐药基因。 \\\\
		\\hline
		\\end{tabular}
		\\end{table}
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} 说明：}
		\\end{spacing}
		\\begin{enumerate}
		\\item 本检测采用荧光PCR技术，低于检测限不能保证可以检出。
		
		\\item 以上结论均为实验室检测数据，仅供临床参考，不能作为最终诊断结果。
		
		\\item 此报告结果仅对本次送检样本负责，报告相关解释须咨询临床医生。
		\\end{enumerate}
		\\vspace{10ex} % 增加空行

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries 检测者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries 审核者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries 报告日期：$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} 附录}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} 参考文献}
		\\end{spacing}";
$content_s{'DX1757'}="\\begin{tabular}{|p{0.33\\textwidth}|p{0.33\\textwidth}|p{0.33\\textwidth}|} 
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{检测结果} \\\\
		\\hline
		检测项目 & 检测内容 & 检测结果 \\\\
		\\hline
		结核分枝杆菌 & 结核分枝杆菌 & \\\\
		\\hline
		\\multirow{4}{*}{利福平耐药基因} & rpoB基因氨基酸507-512突变 & \\\\
		\\cline{2-3}
		\~ & rpoB基因氨基酸512-520突变 & \\\\
		\\cline{2-3}
		\~ & rpoB基因氨基酸520-528突变 & \\\\
		\\cline{2-3}
		\~ & rpoB基因氨基酸528-533突变 & \\\\
		\\hline
		\\end{tabular}}
		\\end{table}
		\\newpage
		\\begin{table}[H]
		\\zihao{-4}{\\bfseries
		\\renewcommand\\arraystretch{0.95} %设置表格行高
		\\begin{tabular}{|p{0.33\\textwidth}|p{0.33\\textwidth}|p{0.33\\textwidth}|} 
		\\hline
		\\multirow{2}{*}{异烟肼耐药基因} & katG(315G>C) & \\\\
		\\cline{2-3}
		\~ & InhA(-15C>T) & \\\\
		\\hline
		\\end{tabular}}
		\\begin{tabular}{|p{1.04\\textwidth}|} %设置表格宽度？？？？？？？
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} 检测结果说明：}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad{\\noindent\\hei\\bfseries\\zihao{4} 结核分枝杆菌c：} 结核分枝杆菌（Mycobacterium tuberculosis，MTB），是引起结核病的病原菌，可侵犯全身各器官，但以肺结核为最多见，还可引起脑膜炎等。\\\\
		\\setlength{\\baselineskip}{18pt}	\\qquad{\\noindent\\hei\\bfseries\\zihao{4} 利福平耐药基因c：} 检测导致结核分枝杆菌利福平耐药的rpoB基因的一段81bp的核心耐药区内的基因突变（该基因的第507位氨基酸\$\\sim\$533位氨基酸，但第533位氨基酸密码子的突变不在此试剂盒的检测范围内）。该区域只要有1个发生阳性突变，说明利福平耐药。 \\\\
		\\setlength{\\baselineskip}{18pt}	\\qquad{\\noindent\\hei\\bfseries\\zihao{4} 异烟肼耐药基因d：} 检测导致结核分枝杆菌异烟肼耐药的katG基因的第315氨基酸的基因突变（K315G>C）与InhA基因的启动子区的基因突变（-15 C>T）。对于katG基因，野生型为GG，杂合突变型为GC，纯合突变型为CC。对于InhA基因，野生型为CC，杂合突变型为CT，纯合突变型为TT。2个基因只要有一个基因发生突变（杂合突变或纯合突变），说明异烟肼耐药。 \\\\
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} 结论：}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad本次检测中，结核分枝杆菌检测结果阳性/阴性； 利福平耐药基因检测结果耐药/不耐药 ；异烟肼耐药基因检测结果耐药/不耐药。 \\\\
		\\hline
		\\end{tabular}
		\\end{table}
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} 说明：}
		\\end{spacing}
		\\begin{enumerate}
		\\item 本检测采用荧光PCR技术，低于检测限不能保证可以检出。
		
		\\item 以上结论均为实验室检测数据，仅供临床参考，不能作为最终诊断结果。
		
		\\item 此报告结果仅对本次送检样本负责，报告相关解释须咨询临床医生。
		\\end{enumerate}
		\\vspace{10ex} % 增加空行

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries 检测者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries 审核者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries 报告日期：$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} 附录}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} 参考文献}
		\\end{spacing}";
$content_s{'DX1759'}="\\begin{tabular}{|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|} %设置表格宽度
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{检测结果} \\\\
		\\hline
		中文名 & 拉丁文名 & 检测结果 \\\\
		\\hline
		甲型流感病毒 & Influenza A virus & \\\\
		\\hline
		乙型流感病毒 & Influenza B virus & \\\\
		\\hline
		\\end{tabular}}
		\\begin{tabular}{|p{1.04\\textwidth}|} %设置表格宽度？？？？？？？
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} 致病性说明：}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad甲型/乙型流感病毒（Influenza A/B virus.）属于正粘病毒科（Orthomyxoviridae），为单链RNA病毒。这两种病毒均为常见的流感病毒，变异率高，流行率高，感染后的临床表现主要有发热、头痛、畏寒、乏力、恶心、咽痛、咳嗽和全身酸痛，严重病例可因肺炎、呼吸衰竭而至死亡\$^{[1]}\$。据世界卫生组织报道，流感病毒每年导致约300万-500万例流感病例，每年造成25万至50万人死亡，20万人住院。自1977年以来，甲型H1N1流感病毒（H1N1），甲型H3N2流感病毒（H3N2）和乙型流感病毒在全球共同传播\$^{[2]}\$。\\\\
		\\hline
		\\end{tabular}
		\\end{table}
		\\newpage
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} 说明：}
		\\end{spacing}
		\\begin{enumerate}
		\\item 本检测采用荧光PCR技术，低于检测限不能保证可以检出。
		
		\\item 以上结论均为实验室检测数据，仅供临床参考，不能作为最终诊断结果。
		
		\\item 此报告结果仅对本次送检样本负责，报告相关解释须咨询临床医生。
		\\end{enumerate}
		\\vspace{10ex} % 增加空行

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries 检测者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries 审核者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries 报告日期：$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} 附录}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} 参考文献}
		\\end{spacing}";
$content_s{'DX1760'}="\\begin{tabular}{|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|} %设置表格宽度
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{检测结果} \\\\
		\\hline
		中文名 & 拉丁文名 & 检测结果 \\\\
		\\hline
		乙型脑炎病毒 & Japanese encephalitis virus & \\\\
		\\hline
		\\end{tabular}}
		\\begin{tabular}{|p{1.04\\textwidth}|} %设置表格宽度？？？？？？？
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} 致病性说明：}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad乙型脑炎病毒（Japanese encephalitis virus，JEV）属于黄病毒科(flaviviridae)，其基因组为单股正链RNA\$^{[1]}\$。乙型脑炎病毒( Japanese encephalitis virus, JEV)可经由蚊虫叮咬传播至人，导致严重的中枢神经系统疾病，称为乙型脑炎，病死率高达30\\% \$\\sim\$ 50\\%，我国是乙脑流行的重要地区\$^{[2]}\$。\\\\
		\\hline
		\\end{tabular}
		\\end{table}
		\\newpage
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} 说明：}
		\\end{spacing}
		\\begin{enumerate}
		\\item 本检测采用荧光PCR技术，低于检测限不能保证可以检出。
		
		\\item 以上结论均为实验室检测数据，仅供临床参考，不能作为最终诊断结果。
		
		\\item 此报告结果仅对本次送检样本负责，报告相关解释须咨询临床医生。
		\\end{enumerate}
		\\vspace{10ex} % 增加空行

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries 检测者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries 审核者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries 报告日期：$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} 附录}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} 参考文献}
		\\end{spacing}";
$content_s{'DX1761'}="\\begin{tabular}{|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|} %设置表格宽度
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{检测结果} \\\\
		\\hline
		中文名 & 拉丁文名 & 检测结果 \\\\
		\\hline
		汉坦病毒 & Hantavirus & \\\\
		\\hline
		\\end{tabular}}
		\\begin{tabular}{|p{1.04\\textwidth}|} %设置表格宽度？？？？？？？
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} 致病性说明：}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad汉坦病毒是一种有包膜分节段的负链RNA病毒，属于布尼亚病毒科。汉坦病毒分为两种：一种引起汉坦病毒肺综合征（HPS），另一种引起汉坦病毒肾综合征出血热（HFRS），前者主要流行于欧美地区，后者即中国常见的由汉滩病毒引起的肾综合征出血热\$^{[1-2]}\$。汉坦病毒汉滩型的发病症状主要表现为肾综合征出血热，以高热、低血压、出血、少尿或多尿等肾功能损伤为主要特征。 \\\\
		\\hline
		\\end{tabular}
		\\end{table}
		\\newpage
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} 说明：}
		\\end{spacing}
		\\begin{enumerate}
		\\item 本检测采用荧光PCR技术，低于检测限不能保证可以检出。
		
		\\item 以上结论均为实验室检测数据，仅供临床参考，不能作为最终诊断结果。
		
		\\item 此报告结果仅对本次送检样本负责，报告相关解释须咨询临床医生。
		\\end{enumerate}
		\\vspace{10ex} % 增加空行

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries 检测者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries 审核者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries 报告日期：$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} 附录}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} 参考文献}
		\\end{spacing}";
$content_s{'DX1762'}="\\begin{tabular}{|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|} %设置表格宽度
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{检测结果} \\\\
		\\hline
		中文名 & 拉丁文名 & 检测结果 \\\\
		\\hline
		新布尼亚病毒 & New bunyavirus & \\\\
		\\hline
		\\end{tabular}}
		\\begin{tabular}{|p{1.04\\textwidth}|} %设置表格宽度？？？？？？？
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} 致病性说明：}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad发热伴血小板减少综合征布尼亚病毒（SFTSV）简称“新布尼亚病毒”，是一种球形、有包膜的负链 RNA病毒\$^{[1,2]}\$，与新疆出血热病毒、汉坦病毒等隶属于布尼亚病毒科\$^{[3]}\$。该病毒在我国多个省份均有报道，呈高度散发，发病季节多在4-10月份，流行高峰为5-9月份，农民或其他从事野外作业人群为主要易感人群。 \\\\
		\\hline
		\\end{tabular}
		\\end{table}
		\\newpage
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} 说明：}
		\\end{spacing}
		\\begin{enumerate}
		\\item 本检测采用荧光PCR技术，低于检测限不能保证可以检出。
		
		\\item 以上结论均为实验室检测数据，仅供临床参考，不能作为最终诊断结果。
		
		\\item 此报告结果仅对本次送检样本负责，报告相关解释须咨询临床医生。
		\\end{enumerate}
		\\vspace{10ex} % 增加空行

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries 检测者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries 审核者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries 报告日期：$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} 附录}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} 参考文献}
		\\end{spacing}";
$content_s{'DX1783'}="\\begin{tabular}{|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|} %设置表格宽度
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{检测结果} \\\\
		\\hline
		中文名 & 拉丁文名 & 检测结果 \\\\
		\\hline
		人腺病毒 & Human adenovirus & \\\\
		\\hline
		\\end{tabular}}
		\\begin{tabular}{|p{1.04\\textwidth}|} %设置表格宽度？？？？？？？
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} 致病性说明：}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad人腺病毒（Human adenovirus，HAdV）属于哺乳动物腺病毒属。HAdV 感染可引起多种疾病，包括肺炎、支气管炎、膀胱炎、 眼结膜炎、胃肠道疾病及脑炎等。与呼吸道感染相关的 HAdV 主要有 B 亚属(HAdV-3、7、11、14、16、21、50、55 型)，C 亚属(HAdV-1、2、5、6、57 型)和 E 亚属(HAdV-4 型)。腺病毒肺炎约占社区获得性肺炎的 4\\%-10\\%，重症肺炎以 3 型及 7 型多见，HAdV-7B 型是 2019 年我国南方发病地区主要流行株。人腺病毒肺炎是儿童社区获得性肺炎中较为严重的类型之一，多发于6个月至5岁儿童，部分患儿临床表现重，肺外并发症多，重症病例易遗留慢性气道和肺疾病，是目前造成婴幼儿肺炎死亡和致残的重要原因之一\$^{[1]}\$ 。 \\\\ 
		\\hline
		\\end{tabular}
		\\end{table}
		\\newpage
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} 说明：}
		\\end{spacing}
		\\begin{enumerate}
		\\item 本检测采用荧光PCR技术，低于检测限不能保证可以检出。
		
		\\item 以上结论均为实验室检测数据，仅供临床参考，不能作为最终诊断结果。
		
		\\item 此报告结果仅对本次送检样本负责，报告相关解释须咨询临床医生。
		\\end{enumerate}
		\\vspace{10ex} % 增加空行

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries 检测者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries 审核者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries 报告日期：$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} 附录}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} 参考文献}
		\\end{spacing}";
$content_s{'DX1784'}="\\begin{tabular}{|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|} %设置表格宽度
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{检测结果} \\\\
		\\hline
		中文名 & 拉丁文名 & 检测结果 \\\\	
		\\hline
		登革热病毒Ⅰ型 & Dengue virus 1 &  \\\\
		\\hline
		登革热病毒Ⅱ型 & Dengue virus 2 &  \\\\
		\\hline
		登革热病毒Ⅲ型 & Dengue virus 3 &  \\\\
		\\hline
		登革热病毒Ⅳ型 & Dengue virus 4 &  \\\\
		\\hline
		\\end{tabular}}
		\\end{table}
		\\begin{table}
		\\begin{tabular}{|p{1.04\\textwidth}|} %设置表格宽度？？？？？？？
		\\hline
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} 致病性说明：}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad登革热（Dengue fever, DF）是由登革热病毒（Dengue virus, DENV）引起的急性传染病，主要通过埃及伊蚊和白纹伊蚊传播[1]。 临床表现主要为高热、头痛、肌肉和关节痛、皮疹、淋巴结肿大及白细胞减少等，严重者可出现出血或休克，甚至死亡[2,3]。 根据抗原性不同分为4个血清型 ( DENV-1，DENV-2，DENV-3 和 DENV-4) ，每种血清型 DENV 均可引起登革热和重症登革热\$^{[4]}\$ 。。 \\\\ 
		\\end{tabular}
		\\begin{tabular}{|p{1.04\\textwidth}|} %设置表格宽度？？？？？？？
		\\hline
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} 结论：}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad本次检测中，登革热病毒检测结果为阳性，检出型别为：登革热病毒Ⅰ型、登革热病毒Ⅱ型、登革热病毒Ⅲ型、登革热病毒Ⅳ型。 \\\\  \\qquad本次检测中，登革热病毒检测结果为阴性，未检出本产品检测范围内型别。\\\\
		\\hline
		\\end{tabular}
		\\end{table}
		\\newpage
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} 说明：}
		\\end{spacing}
		\\begin{enumerate}
		\\item 本检测采用荧光PCR技术，低于检测限不能保证可以检出。
		
		\\item 以上结论均为实验室检测数据，仅供临床参考，不能作为最终诊断结果。
		
		\\item 此报告结果仅对本次送检样本负责，报告相关解释须咨询临床医生。
		\\end{enumerate}
		\\vspace{10ex} % 增加空行

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries 检测者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries 审核者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries 报告日期：$date}
		
		\\vspace{2cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} 附录}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} 参考文献}
		\\end{spacing}";
$content_s{'DX1796'}="\\begin{tabular}{|p{0.24\\textwidth}<{\\centering}|p{0.24\\textwidth}<{\\centering}|p{0.24\\textwidth}<{\\centering}|p{0.24\\textwidth}<{\\centering}|} %设置表格宽度
		\\rowcolor{mygray}\\multicolumn{4}{|c|}{检测结果} \\\\
		\\hline
		\\rowcolor{mygray}\\multicolumn{2}{|c|}{Sanger测序结果 } & \\multicolumn{2}{c|}{序列比对结果 }\\\\
		\\hline
		病毒 & 检出结果 & 中文名 & 拉丁文名 \\\\	
		\\hline	
		肠道病毒 & 阳性 &  &  \\\\
		\\hline
		肠道病毒 & 阴性 & 未检出 &  \\\\
		\\hline
		\\end{tabular}}
		\\end{table}
		\\begin{table}
		\\begin{tabular}{|p{1.04\\textwidth}|} %设置表格宽度？？？？？？？
		\\hline
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} 致病性说明：}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad肠道病毒（Enterovirus, EV）属于小RNA病毒科肠道病毒属, 包括脊髓灰质炎病毒（Poliovirus）、埃可病毒 （Echovirus）、柯萨奇病毒（Coxsackievirus）新型肠道病毒。迄今为止发现的病毒型别多达70余种。肠道病毒感染临床表现复杂多变，病情轻重差别甚大，临床表现轻者只有倦怠、乏力、低热等﹐重者可全身感染﹐脑、脊髓、心、肝等重要器官受损，预后较差，并可遗留后遗症或造成死亡。主要临床症候有：呼吸道感染、手足口病、脑炎脑膜炎、流行性皮疹、疱疹性咽峡炎等。临床表现与病情轻重与不同型别病毒感染存在一定关系，如EV71、COXA6、ECHO6、11、18型等致病力较强。成人和儿童均可发病﹐儿童较多见且重症感染往往为7岁以下儿童。肠道病毒感染也是引起儿童院感的重要病毒之一。 \\\\ 
		\\hline
		\\end{tabular}
		\\begin{tabular}{|p{1.04\\textwidth}|} %设置表格宽度？？？？？？？
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} 结论：}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad本次检测，肠道病毒检测结果为阳性，检出型别为……。 \\\\  \\qquad本次检测，肠道病毒检测结果为阴性，未检出本产品检测范围内型别。\\\\
		\\hline
		\\end{tabular}
		\\end{table}
		\\newpage
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} 说明：}
		\\end{spacing}
		\\begin{enumerate}
		\\item 本检测采用PCR扩增结合Sanger测序技术对肠道病毒进行分型检测。
		
		\\item 由于肠道病毒亚型较多，序列存在突变或病毒载量较低、样本不合理采集等情况可能导致PCR 扩增结果为阴性。
		
		\\item 若样本病毒拷贝数低于检出限，会显示检出肠道病毒样本，但Sanger测序失败，无法分型。
		
		\\item 以上结论均为实验室检测数据，仅供临床参考，不能作为最终诊断结果。具体结果需结合临床体征、病史、其他实验室检查及治疗反应等情况综合考虑。
		
		\\item 此报告结果仅对本次送检样本负责，报告相关解释须咨询临床医生。 
		
		\\end{enumerate}
		\\vspace{10ex} % 增加空行

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries 检测者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries 审核者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries 报告日期：$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} 附录}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} 参考文献}
		\\end{spacing}";
		
$content_s{'SD0221'}="\\begin{tabular}{|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|} %设置表格宽度
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{检测结果} \\\\
		\\hline
		中文名 & 拉丁文名 & 检测结果 \\\\
		\\hline
		2019新型冠状病毒 & 2019-nCoV & $res{$sid}\\\\
		\\hline
		\\end{tabular}}
		\\begin{tabular}{|p{1.04\\textwidth}|} %设置表格宽度？？？？？？？
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} 致病性说明：}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad2019年12月底，武汉市部分医疗机构陆续出现不明原因肺炎病人，经专家组鉴定为一种新型冠状病毒，世界卫生组织（WHO）已将此次检出之病毒命名为2019-nCoV（2019新型冠状病毒）。对此新型冠状病毒的了解还需要进一步科学研究，但实现对该病毒的快速准确检测，仍然是一种有效的防控手段。 \\\\ 
		\\hline
		\\end{tabular}
		\\end{table}
		\\newpage
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} 说明：}
		\\end{spacing}
		\\begin{enumerate}
		\\item 本检测采用荧光PCR技术，低于检测限不能保证可以检出。
		
		\\item 以上结论均为实验室检测数据，仅供临床参考，不能作为最终诊断结果。
		
		\\item 此报告结果仅对本次送检样本负责，报告相关解释须咨询临床医生。
		\\end{enumerate}
		\\vspace{10ex} % 增加空行

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries 检测者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries 审核者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries 报告日期：$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} 附录}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} 参考文献}
		\\end{spacing}";

$content_s{'DX1867'}="\\begin{tabular}{|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|} %设置表格宽度
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{检测结果} \\\\
		\\hline
		中文名 & 拉丁文名 & 检测结果\\\\	
		\\hline	
		甲型流感病毒 & Influenza A virus,IAV &  \\\\
		\\hline
		乙型流感病毒 & Influenza B virus,IBV &  \\\\
		\\hline
		呼吸道合胞病毒 & Respiratory syncytial virus, RSV &  \\\\
		\\hline
		人腺病毒 & Human adenovirus, HAdV &  \\\\
		\\hline
		人鼻病毒 & Human rhinovirus, HRV &  \\\\
		\\hline
		肺炎支原体 & Mycoplasma Pneumoniae, MP &  \\\\
		\\hline
		\\end{tabular}}
		\\end{table}
		\\newpage
		\\topskip 0.1cm	
	\\begin{longtable}{|p{1.04\\textwidth}|} %设置表格宽度？？？？？？？
		\\hline
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} 致病性说明：}
		\\end{spacing}
		
		\\zihao{-4}\\setlength{\\baselineskip}{18pt}	\\qquad甲型/乙型流感病毒（Influenza A/B virus,IAV/IBV）属于正粘病毒科（Orthomyxoviridae），为单链RNA病毒。这两种病毒均为常见的流感病毒，变异率高，流行率高，感染后的临床表现主要有发热、头痛、畏寒、乏力、恶心、咽痛、咳嗽和全身酸痛，严重病例可因肺炎、呼吸衰竭而致死亡\$^{[1]}\$。据世界卫生组织报道，流感病毒每年导致约300万-500万例流感病例，每年造成25万至50万人死亡，20万人住院。自1977年以来，甲型H1N1流感病毒（H1N1），甲型H3N2流感病毒（H3N2）和乙型流感病毒在全球共同传播\$^{[2-3]}\$。\\\\

		\\zihao{-4}\\setlength{\\baselineskip}{18pt}	\\qquad呼吸道合胞病毒（Respiratory syncytial virus，RSV）是一种RNA病毒，属于副粘病毒，该病毒经空气飞沫和密切接触传播，引起婴幼儿下呼吸道感染的主要病原；婴幼儿感染RSV后可发生严重的毛细支气管炎(简称毛支)和肺炎，与儿童哮喘有一定的关联，婴幼儿症状较重，可有高热、鼻炎、咽炎及喉炎，以后表现为细支气管炎及肺炎。少数病儿可并发中耳炎、胸膜炎及心肌炎等。成人和年长儿童感染后，主要表现为上呼吸道感染\$^{[4]}\$。\\\\

		\\zihao{-4}\\setlength{\\baselineskip}{18pt}	\\qquad人腺病毒（Human adenovirus, HAdV）为无包膜的双链DNA病毒，目前已发现至少90个基因型，分为A-G共7个亚属。呼吸道感染相关的HAdV主要有B亚属、C亚属和E亚属（HAdV-4型）。腺病毒肺炎约占社区获得性肺炎的4%-10%，重症肺炎以3型及7型多，是儿童社区获得性肺炎中较为严重的类型之一\$^{[5]}\$。\\\\

		\\zihao{-4}\\setlength{\\baselineskip}{18pt}	\\qquad人鼻病毒（Human rhinovirus，HRV）小RNA病毒科、肠病毒属的一种，是人患普通感冒的主要病原，对普通感冒尚无特异预防和治疗方法；有时会引起诸如哮喘、充血性心衰、支气管扩张，包囊纤维化等严重并发症，并且HRV多与其它呼吸道病毒合并感染，例如呼吸道合胞病毒、腺病毒等\$^{[6]}\$。\\\\

		\\zihao{-4}\\setlength{\\baselineskip}{18pt}	\\qquad肺炎支原体（M.Pneumonia，M.p）是一种大小介于细菌和病毒之间的致病微生物，支原体肺炎的病理改变以间质性肺炎为主，有时并发支气管肺炎，称为原发性非典型性肺炎。主要经飞沫传染，潜伏期2～3周，发病率以青少年最高。临床症状较轻，甚至根本无症状，若有也只是头痛、咽痛、发热、咳嗽等一般的呼吸道症状，但也有个别死亡报道。一年四季均可发生\$^{[7]}\$。\\\\
		\\hline

		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} 结论：}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad本次检测中，呼吸道病原体检测结果为阳性，检出病原为：【任意病原名称，当出现多个需要用、隔开】。 \\\\  
		\\setlength{\\baselineskip}{18pt}	\\qquad本次检测中，呼吸道病原体检测结果为阴性，未检出本产品检测范围内病原。\\\\
		\\hline
		\\end{longtable}
		
		\\newpage
		\\topskip 0.1cm
		\\begin{longtable}{p{1.04\\textwidth}}
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} 说明：}
		\\end{spacing}
		\\begin{enumerate}
		\\item 本检测采用PCR扩增结合Sanger测序技术对肠道病毒进行分型检测。
		
		\\item 由于肠道病毒亚型较多，序列存在突变或病毒载量较低、样本不合理采集等情况可能导致PCR 扩增结果为阴性。
		
		\\item 若样本病毒拷贝数低于检出限，会显示检出肠道病毒样本，但Sanger测序失败，无法分型。
		
		\\item 以上结论均为实验室检测数据，仅供临床参考，不能作为最终诊断结果。具体结果需结合临床体征、病史、其他实验室检查及治疗反应等情况综合考虑。
		
		\\item 此报告结果仅对本次送检样本负责，报告相关解释须咨询临床医生。 
		
		\\end{enumerate}
		\\vspace{10ex} % 增加空行

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries 检测者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries 审核者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries 报告日期：$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} 附录}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} 参考文献}
		\\end{spacing}";

$content_s{'DX1868'}="\\begin{tabular}{|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|} %设置表格宽度
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{检测结果} \\\\
		\\hline
		中文名 & 拉丁文名 & 检测结果\\\\	
		\\hline	
		甲型流感病毒 & Influenza A virus,IAV &  \\\\
		\\hline
		乙型流感病毒 & Influenza B virus,IBV &  \\\\
		\\hline
		呼吸道合胞病毒 & Respiratory syncytial virus, RSV &  \\\\
		\\hline
		人腺病毒 & Human adenovirus, HAdV & \\\\
		\\hline
		人鼻病毒 & Human rhinovirus, HRV &  \\\\
		\\hline
		肺炎支原体 & Mycoplasma Pneumoniae MP & \\\\
		\\hline
		2019新型冠状病毒  & 2019-nCoV MP &  \\\\
		\\hline
		\\end{tabular}}
		\\end{table}
		\\newpage
		\\topskip 0.1cm	
	\\begin{longtable}{|p{1.04\\textwidth}|} %设置表格宽度？？？？？？？
		\\hline
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} 致病性说明：}
		\\end{spacing}
		
		\\zihao{-4}\\setlength{\\baselineskip}{16pt}	\\qquad甲型/乙型流感病毒（Influenza A/B virus,IAV/IBV）属于正粘病毒科（Orthomyxoviridae），为单链RNA病毒。这两种病毒均为常见的流感病毒，变异率高，流行率高，感染后的临床表现主要有发热、头痛、畏寒、乏力、恶心、咽痛、咳嗽和全身酸痛，严重病例可因肺炎、呼吸衰竭而致死亡\$^{[1]}\$。据世界卫生组织报道，流感病毒每年导致约300万-500万例流感病例，每年造成25万至50万人死亡，20万人住院。自1977年以来，甲型H1N1流感病毒（H1N1），甲型H3N2流感病毒（H3N2）和乙型流感病毒在全球共同传播\$^{[2-3]}\$。\\\\

		\\zihao{-4}\\setlength{\\baselineskip}{16pt}	\\qquad呼吸道合胞病毒（Respiratory syncytial virus，RSV）是一种RNA病毒，属于副粘病毒，该病毒经空气飞沫和密切接触传播，引起婴幼儿下呼吸道感染的主要病原；婴幼儿感染RSV后可发生严重的毛细支气管炎(简称毛支)和肺炎，与儿童哮喘有一定的关联，婴幼儿症状较重，可有高热、鼻炎、咽炎及喉炎，以后表现为细支气管炎及肺炎。少数病儿可并发中耳炎、胸膜炎及心肌炎等。成人和年长儿童感染后，主要表现为上呼吸道感染\$^{[4]}\$。\\\\

		\\zihao{-4}\\setlength{\\baselineskip}{16pt}	\\qquad人腺病毒（Human adenovirus, HAdV）为无包膜的双链DNA病毒，目前已发现至少90个基因型，分为A-G共7个亚属。呼吸道感染相关的HAdV主要有B亚属、C亚属和E亚属（HAdV-4型）。腺病毒肺炎约占社区获得性肺炎的4%-10%，重症肺炎以3型及7型多，是儿童社区获得性肺炎中较为严重的类型之一\$^{[5]}\$。\\\\

		\\zihao{-4}\\setlength{\\baselineskip}{16pt}	\\qquad人鼻病毒（Human rhinovirus，HRV）小RNA病毒科、肠病毒属的一种，是人患普通感冒的主要病原，对普通感冒尚无特异预防和治疗方法；有时会引起诸如哮喘、充血性心衰、支气管扩张，包囊纤维化等严重并发症，并且HRV多与其它呼吸道病毒合并感染，例如呼吸道合胞病毒、腺病毒等\$^{[6]}\$。\\\\

		\\zihao{-4}\\setlength{\\baselineskip}{16pt}	\\qquad肺炎支原体（M.Pneumonia，M.p）是一种大小介于细菌和病毒之间的致病微生物，支原体肺炎的病理改变以间质性肺炎为主，有时并发支气管肺炎，称为原发性非典型性肺炎。主要经飞沫传染，潜伏期2～3周，发病率以青少年最高。临床症状较轻，甚至根本无症状，若有也只是头痛、咽痛、发热、咳嗽等一般的呼吸道症状，但也有个别死亡报道。一年四季均可发生\$^{[7]}\$。\\\\
		
		\\zihao{-4}\\setlength{\\baselineskip}{16pt}	\\qquad2019新型冠状病毒（2019-nCoV）是2019年新发现的一种新型冠状病毒，属于β冠状病毒属，是2019新型冠状病毒疾病（COVID-19）的病原体，已在世界范围内广泛传播，并引起多个国家的COVID-19爆发。该病毒的传染性较强，潜伏期1-14天，无症状感染者也可能成为传染源，呼吸道飞沫传播及密切接触传播是主要的传播途径。该病毒常在COVID-19患者的呼吸道样本中发现，有文献报道在患者的粪便、尿液中也有检测到\$^{[8-11]}\$。\\\\
		\\hline

		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} 结论：}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad本次检测中，呼吸道病原体检测结果为阳性，检出病原为：【任意病原名称，当出现多个需要用、隔开】。 \\\\  
		\\setlength{\\baselineskip}{18pt}	\\qquad本次检测中，呼吸道病原体检测结果为阴性，未检出本产品检测范围内病原。\\\\
		\\hline
		\\end{longtable}
		
		\\newpage
		\\topskip 0.1cm
		\\begin{longtable}{p{1.04\\textwidth}}
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} 说明：}
		\\end{spacing}
		\\begin{enumerate}
		\\item 本检测采用PCR扩增结合Sanger测序技术对肠道病毒进行分型检测。
		
		\\item 由于肠道病毒亚型较多，序列存在突变或病毒载量较低、样本不合理采集等情况可能导致PCR 扩增结果为阴性。
		
		\\item 若样本病毒拷贝数低于检出限，会显示检出肠道病毒样本，但Sanger测序失败，无法分型。
		
		\\item 以上结论均为实验室检测数据，仅供临床参考，不能作为最终诊断结果。具体结果需结合临床体征、病史、其他实验室检查及治疗反应等情况综合考虑。
		
		\\item 此报告结果仅对本次送检样本负责，报告相关解释须咨询临床医生。 
		
		\\end{enumerate}
		\\vspace{10ex} % 增加空行

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries 检测者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries 审核者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries 报告日期：$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} 附录}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} 参考文献}
		\\end{spacing}";

$content_QM ="
		\\documentclass[UTF8]{ctexart}
		%-------------------------------------------------------------导言-------------------------
		\\usepackage[T1]{fontenc} %设置text格式下划线
		\\usepackage{lmodern} %设置text格式下划线
		\\usepackage{geometry}
		\\usepackage{multirow}
		\\usepackage{float}%浮动包
		\\usepackage{colortbl}%设置表格行高
		\\definecolor{lightgray}{RGB}{245,245,245}
		\\usepackage{makecell} %设置表格线
		\\usepackage{booktabs} %表格线粗细
		\\usepackage{fancyhdr}%插入页眉页脚页码包
		\\usepackage{graphicx} % 图形宏包
		\\usepackage{colortbl} %表格颜色包
		\\usepackage{setspace}%使用间距宏包
		\\usepackage{CJK,CJKnumb} %设置字体
		\\usepackage{array}%表格固定列宽内容居中
		%\\usepackage{natbib}
		%\\usepackage[superscript]{cite} % 文献上标
		\\usepackage[super,square,comma,sort&compress]{natbib}
		\\usepackage[normalem]{ulem}%添加下划线
		\\usepackage{lastpage}%获得总页数
		\\usepackage{enumerate} %列表
		\\usepackage{enumitem} %设置列表间隔
		\\setlist[enumerate,1]{label=\\arabic*、,leftmargin=7mm,labelsep=1.5mm,topsep=0mm,itemsep=-0.8mm}
		%添加水印
		\\usepackage{tikz}
		\\usepackage{xcolor}
		\\usepackage{eso-pic}
		%添加水印
		\\usepackage{longtable} %表格分页
		\\usepackage{longtable}
		\\usepackage{tabu}
		\\usepackage{overpic} %封面添加患者信息
		%------------------------------------------------------结束-------------------------------
	%水印
	\\newcommand\\BackgroundPicture{
		 \\put(0,0){
			\\parbox[b][\\paperheight]{\\paperwidth}{
				\\vfill
				      \\centering
					  \\begin{tikzpicture}[remember picture,overlay]
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at (current page.center) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=5cm,yshift=0cm]current page.west) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=-5cm,yshift=0cm]current page.east) {\\textcolor{gray!80!cyan!30}{PMseq}};

					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=0cm,yshift=-7cm]current page.north) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=-5cm,yshift=-7cm]current page.north east) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=5cm,yshift=-7cm]current page.north west) {\\textcolor{gray!80!cyan!30}{PMseq}};

					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=0cm,yshift=7cm]current page.south) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=5cm,yshift=7cm]current page.south west) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=-5cm,yshift=7cm]current page.south east) {\\textcolor{gray!80!cyan!30}{PMseq}};

			\\end{tikzpicture}
			\\vfill
			}
		}
	}
%水印
		\\definecolor{mygray}{gray}{.9}
		\\definecolor{myback}{gray}{.9}
		\\definecolor{myblue}{RGB}{0,74,143}
		\\definecolor{myorange}{RGB}{243,152,0}
		%\\definecolor{myback}{RGB}{252,228,214}
		%\\newCJKfontfamily\\msyh{微软雅黑}
		%\\setCJKfamilyfont{yh}{Microsoft YaHei}


		\\newcommand{\\song}{\\CJKfamily{song}}    % 宋体
		\\newcommand{\\fs}{\\CJKfamily{fs}}             % 仿宋体
		\\newcommand{\\kai}{\\CJKfamily{kai}}          % 楷体
		\\newcommand{\\hei}{\\CJKfamily{hei}}         % 黑体
		\\newcommand{\\li}{\\CJKfamily{li}}               % 隶书

		%-----------------------------------------------结束-------------------------
		\\geometry{a4paper,centering,scale=0.8}
		\\pagestyle{fancy} %插入页眉页脚
		%\\graphicspath{{C:/Users/mabingyin/Desktop/Plus产品小程序/Plus产品小程序版本更新/V2.2/TJ/}}
		\\graphicspath{{C:/CTEX/Pictures/}}

		%-------------------------------------------------页眉插入图片-------------
		\\newsavebox{\\headpic}
		\\sbox{\\headpic}{\\includegraphics[height=2cm]{Y13-qPCR-XJNY-191028-QM.jpg}} %设置页眉logo页眉
		\\fancyhead[l]{\\usebox{\\headpic}}
		 
		\\fancyhead[c]{\\zihao{-5}姓名：$name \\hspace{10cm}  采样日期：$collect_date }
		%--------------------------------------------------结束---------------------

		%----------------------------------------------设置页眉页脚格式------------
		
		\\rhead{\\zihao{-5} \\uline{\\hspace{14cm}DX-PMP-B60 V1.1} \\vspace{0.1ex}   }
		 \\lfoot{\\zihao{-5} 客服电话：400-6057-268  \\hspace{0.8cm} 网址:www.cmlabs.com.cn}
		\\cfoot{}%有该命令，页脚中间不出现页码
		%\\rfoot{\\thepage}
		\\rfoot{\\thepage \\ / \\pageref{LastPage}}
		\\renewcommand{\\headrulewidth}{0.2pt}%改为0pt即可去掉页脚上面的横线   
		\\renewcommand{\\footrulewidth}{0.2pt}
		%-------------------------------------------------结束--------------------
		\\setlength{\\extrarowheight}{4mm} %表格行高

		%------------------------------------------开始正文--------------------------
		\\begin{document}
		\\bibliographystyle{unsrt} % 按文献在正文中引用的顺序排序
	
		%-----------------------------------------首页插入图片----------------------
		\\newgeometry{left=0.8cm,bottom=0cm,right=0.8cm,top=0cm} %更改单个页面页边距 
		\\setcounter{page}{0} %页码1从第二页开始
		\\thispagestyle{empty} %首页不显示页眉页脚
		\\begin{overpic}[width=\\textwidth,height=\\textheight,,keepaspectratio]{F13-qPCR-XJNY-191129-QM.png} 
		\\put(21,10){\\begin{tabular}{cp{270 pt}<{\\centering}}%19
		\\cline{2-2}
		\\textcolor{myorange}{\\zihao{3}\\bfseries $hospital}\\\\ 
		
		\\cline{2-2}
		\\end{tabular}}
		\\end{overpic}
		\\restoregeometry %恢复到原来的页边距
		%------------------------------------------------------结束-----------------------------
		\\newpage
		\\topskip 1.5cm
		%\\vspace{6mm}%页眉横线与正文间的垂直间距

		\\noindent %顶格，不缩进
		{\\hei\\zihao{4}\\bfseries 一 \\quad 基本信息} %如何设置使得距离页眉的距离跟检测结果一样？
		%-------------------------------------------------------开始表格-----------------------------------------------------
		\\begin{table}[H]
		\\zihao{-5}{\\bfseries
		\\renewcommand\\arraystretch{0.95} %设置表格行高
		\\begin{tabular}{p{0.33\\textwidth}p{0.33\\textwidth}p{0.33\\textwidth}} %设置表格宽度
		\\hline
		\\rowcolor{orange!35}\\multicolumn{3}{l}{受检者信息} \\\\%竖线的作用？
		\\hline
		姓名：$name & 性别：$sex & 年龄： $age \\\\
		\\hline
		住院号：$hosnum & 床号：$bednum & 原样本编号： $origin_id  \\\\
		\\hline
		\\rowcolor{orange!35}\\multicolumn{3}{l}{临床信息} \\\\
		\\hline
		\\multicolumn{3}{p{\\textwidth}}{ 临床表现：$manifestation} \\\\
		\\hline
		\\multicolumn{3}{p{\\textwidth}}{临床检测} \\\\
		\\hline
		\\end{tabular}
		\\begin{tabular}{p{0.243\\textwidth}p{0.24\\textwidth}p{0.24\\textwidth}p{0.24\\textwidth}} %设置表格宽度？
		血WBC：$wbc & 脑脊液WBC：$ly & 胸腹水WBC：$neu & CRP：$crp \\\\
		\\hline
		PCT：$pct & 培养结果：$culture & 鉴定结果：$identify & 镜检结果：$microscopy \\\\
		\\hline
		
		\\multicolumn{4}{p{\\textwidth}}{临床诊断：$diagnosis} \\\\
		\\hline
		\\multicolumn{4}{p{\\textwidth}}{重点关注病原：$pathogen} \\\\
		\\hline
		\\multicolumn{4}{p{\\textwidth}}{抗感染用药：$drug} \\\\
		\\hline
		\\rowcolor{orange!35}\\multicolumn{4}{l}{样本信息} \\\\
		\\end{tabular}
		\\begin{tabular}{p{0.33\\textwidth}p{0.33\\textwidth}p{0.33\\textwidth}} %设置表格宽度
		\\hline
		送检单位：$hospital & 送检科室：$department & 送检医师：$doctor  \\\\
		\\hline
		采样日期：$collect_date & 收样日期：$recept_date & 报告日期：$date \\\\
		\\hline
		样本编号：$sid & 样本类型：$sptype &  样本体积：$spvolume  \\\\
	     \\hline
		\\end{tabular}}
		\\end{table}
		
		\\vspace{5ex} % 增加空行
		\\noindent %顶格，不缩进		
		{\\hei\\zihao{-4}\\bfseries 二 \\quad 检测结果} %如何设置使得距离页眉的距离跟检测结果一样？
		%-------------------------------------------------------开始表格-----------------------------------------------------
		\\topskip 0cm
		{\\song\\bfseries\\zihao{-5} %表格字体
	\\begin{longtable}
		{p{0.24\\textwidth}p{0.24\\textwidth}p{0.24\\textwidth}p{0.24\\textwidth}}
		\\toprule[0.1pt]

		\\multicolumn{4}{>{\\columncolor{orange!35}}l}{\\zihao{-5}检测结果}   \\\\
		\\midrule
		{\\zihao{4}} 耐药基因 & 对应酶 & 耐药谱 & 检测结果  \\\\
		\\midrule
		CTX-M1 & β-内酰胺酶 & 可导致阿莫西林、哌拉西林、头孢呋辛、头孢噻肟、先锋霉素类药物抗性，对氨曲南也有抗性 & \\\\
		\\midrule
		KPC & 碳青霉烯酶 & 可导致亚胺培南、厄他培南、哌拉西林、头孢曲松钠、头孢吡肟、氨曲南、氨苄西林、头孢噻肟、头孢他啶、美罗培南等抗性 & \\\\
		\\midrule
		IMP & 金属β-内酰胺酶 & 可导致氨苄西林、替卡西林、头孢唑啉、头孢他啶、亚胺培南、美罗培南等碳青霉烯类，头孢菌素类药物抗性 & \\\\
		\\midrule
		VIM & 金属β-内酰胺酶 & 可导致头孢西丁、头孢曲松钠、头孢唑啉、头孢他啶、亚胺培南、美罗培南等碳青霉烯类，头孢菌素类药物抗性 & \\\\
		\\midrule
		NDM & 金属β-内酰胺酶 & 可导致头孢噻肟、头孢他啶、头孢曲松钠、美罗培南、多利培南、亚胺培南等抗性 & \\\\
		\\midrule
		SIM & 金属β-内酰胺酶 & 可导致头孢菌素类、碳青霉烯类药物抗性 & \\\\
		\\midrule
		DIM & 金属β-内酰胺酶 & 可导致头孢西丁、阿莫西林、替卡西林、哌拉西林、头孢噻肟、亚胺培南等抗性 & \\\\
		\\midrule
		%\\bottomrule[1.2pt]
	\\end{longtable}}
          
		\\noindent\\zihao{5}{\\song\\bfseries 检测说明：}
 
		{\\zihao{5}{\\song本检测适用于体外定性检测导致细菌耐药相关蛋白酶基因，包括表达啶型超广谱β-内酰胺酶的CTX-M1型别基因，引起碳青霉烯类耐药碳青霉烯酶两类基因，即大多位于质粒上的碳青霉烯酶基因的A类（KPC）、B类（IMP,VIM,NDM,SIM,DIM）共7项耐药相关基因，为细菌耐药患者的诊治提供辅助手段。\\\\}}

		\\noindent\\zihao{5}{\\song\\bfseries 结论：}

		\\zihao{5}{\\song本次检测中，细菌耐药检测结果为阳性，检出耐药基因CTX-M1/KPC/ IMP/VIM/NDM/SIM/DIM，可导致药物抗性见检测结果耐药谱。本次检测中，细菌耐药检测结果为阴性，未检出本产品检测范围内的耐药基因。\\\\}

		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} 参考文献}
		\\end{spacing}
		
		{\\noindent\\zihao{5} 1.	Anjum M F , Zankari E , Hasman H . Molecular Methods for Detection of Antimicrobial Resistance[J]. Microbiology Spectrum, 2017, 5(6).}

		{\\noindent\\zihao{5} 2.	Mcdonald L C , Kuehnert M J , Tenover F C , et al. Vancomycin-resistant enterococci outside the health-care setting: prevalence, sources, and public health implications.[J]. Emerging Infectious Diseases, 1997, 3(3):311.}

		{\\noindent\\zihao{5} 3.	李金明.实时荧光PCR技术.人民军医出版社，2007.  }

		{\\noindent\\zihao{5} 4.	喻浠明,李畅,张文慧,贾宇,张林波.细菌间bla\\_(NDM-1)传播规律的研究进展[J].生命科学,2018,30(11):1244-1251. }

		{\\noindent\\zihao{5} 5.	张珍珍,吴俊伟,杨卫军.细菌耐药性产生的分子生物学机理及控制措施[J].动物医学进展,2008(02):106-109. }

		{\\noindent\\zihao{5} 6.	Murakami K , Minamide W , Wada K , et al. Identification of methicillin-resistant strains of staphylococci by polymerase chain reaction.[J]. Journal of Clinical Microbiology, 1991, 29(10):2240-2244. }

		{\\noindent\\zihao{5} 7.	甘龙杰,陈善建,林宇岚,陈守涛,杨滨.碳青霉烯类耐药肠杆菌科细菌基因型检测及耐药性分析[J].临床检验杂志,2018,36(09):663-666. }

		{\\noindent\\zihao{5} 8.	Dallenne C , Costa A D , Dominique Decré, et al. Development of a set of multiplex PCR assays for the detection of genes encoding important beta-lactamases in Enterobacteriaceae.[J]. Journal of Antimicrobial Chemotherapy, 2010, 65(3):490. }

		{\\noindent\\zihao{5} 9.	Solanki R , Vanjari L , Subramanian S , et al. Comparative Evaluation of Multiplex PCR and Routine Laboratory Phenotypic Methods for Detection of Carbapenemases among Gram Negative Bacilli.[J]. J Clin Diagn Res, 2014, 8(12):23-6. }

		{\\noindent\\zihao{5} 10.	Poirel L , Walsh T R , Cuvillier V , et al. Multiplex PCR for detection of acquired carbapenemase genes[J]. Diagnostic Microbiology and Infectious Disease, 2011, 70(1):0-123. }

		\\vspace{20ex} % 增加空行
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} 三 \\quad 声明：}
		\\end{spacing}
		\\begin{enumerate}
		\\item 本检测采用荧光PCR技术，低于检测限不能保证可以检出。
		\\vspace{2ex}
		\\item 以上结论均为实验室检测数据，仅供临床参考，不能作为最终诊断结果。
		\\vspace{2ex}
		\\item 此报告结果仅对本次送检样本负责，报告相关解释须咨询临床医生。
		\\end{enumerate}
		\\vspace{10ex} % 增加空行

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries 检测者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries 审核者：}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries 报告日期：$date}
		\\end{document}";


$content_r{'DX1749'}="
{\\noindent\\zihao{5}[1] 程敬伟, 刘文恩, 马小军,等. 中国成人艰难梭菌感染诊断和治疗专家共识[J]. 协和医学杂志, 2017, 8(2):131-138.}

{\\noindent\\zihao{5}[2] 王芊, 华川. 艰难梭菌感染的相关研究进展[J]. 临床误诊误治, 2015(8):105-108.}

{\\noindent\\zihao{5}[3] 陈丽丹. 不同来源的艰难梭菌其毒素、MLST分型及药敏情况的分析[D]. 南方医科大学, 2016. }

{\\noindent\\zihao{5}[4] 景东, 吴琳, 王毅谦,等. 实时荧光PCR快速检测粪便中艰难梭菌方法[J]. 中国卫生检验杂志, 2011(7):1604-1606. }

\\end{document}
";

$content_r{'DX1763'}="
{\\noindent\\zihao{5}[1] 王家良.《临床流行病学》人民卫生出版社，2002。}

{\\noindent\\zihao{5}[2] 李东力等. 手足口病流行病学与防控对策.沈阳部队医药. 2008。}

{\\noindent\\zihao{5}[3] 中华人民共和国卫生部.手足口病诊疗指南 (2008年版)。\\\\ http://www.gov.cn/gzdt/2008-12/12/content\\_1176057.htm  }

{\\noindent\\zihao{5}[4] Xiao XL et al. Simultaneous detection of human enterovirus71 and coxsackievirus A16 in clinical specimens by multiplex real-time PCR with an internal amplification control. }

\\end{document}
";
$content_r{'DX1759'}="
{\\noindent\\zihao{5}[1] 陈继明,郭元吉.乙型流行性感冒病毒两大谱系的起源及其演变特征. 病毒学报2001(4).}

{\\noindent\\zihao{5}[2] 舒跃龙等. 2004-2005年中国A（H1N1）亚型流感病毒抗原性及基因特性研究。临床医学，2006。}

{\\noindent\\zihao{5}[3] 王敏,郭元吉. 当前流行的乙型流感病毒血凝素蛋白抗原性及其基因特性. 《中华实验和临床病毒学杂志》1995(3).}

{\\noindent\\zihao{5}[4] Novel Swine-Origin Influenza A (H1N1) Virus Investigation Team. Emergence of a Novel Swine-Origin Influenza A (H1N1) Virus in Humans. N Engl J Med，2009.}

{\\noindent\\zihao{5}[5] M W Shaw, R A Lamb, and P W Choppin. Proc Natl Acad Sci U S A. 1982 ;79(22). }

{\\noindent\\zihao{5}[6] Yamashita M, Krystal M, Fitch WM, Palese P. Influenza B virus evolution: co-circulating lineages and comparison of evolutionary pattern with those of influenza A and C viruses. Virology. 1988;163(1).}

\\end{document}
";

$content_r{'DX1760'}="
{\\noindent\\zihao{5}[1] 张丹, 金扩世, 金宁一等. 乙型脑炎病毒分子生物学特性及检测方法研究进展[J]. 中国动物检疫. 2009,26:70-72.}

{\\noindent\\zihao{5}[2] 刘卫滨, 付士红, 宋宏等. 乙型脑炎病毒 TaqMan PCR 检测方法的建立及初步应用[J]. 中华微生物学和免疫学杂志. 2007,22:420-422.}

{\\noindent\\zihao{5}[3] M. M. Parida, S. R. Santhosh, P. K. Dash, N. K. Tripathi, P. Saxena, S. Ambuj, A. K. Sahni, P. V. Lakshmana Rao and Kouichi Morita. Development and Evaluation of Reverse Transcription–Loop-Mediated Isothermal Amplification Assay for Rapid and Real-Time Detection of Japanese Encephalitis Virus [J].Journal of Clinical Microbiology，2006, 44:4172-4178.}

\\end{document}
";

$content_r{'DX1761'}="
{\\noindent\\zihao{5}[1] 丁晓华, 杨占秋, 肖红等. RT-PCR扩增汉滩病毒及其核苷酸序列的发生树分析[J]. 中华微生物学和免疫学杂志. 2003,23: 38-41.}

{\\noindent\\zihao{5}[2] 王世文，杭长寿，王华等. 我国汉坦病毒基因型和基因亚型的分布研究[J]. 病毒学报. 2002， 18：211-216.}

{\\noindent\\zihao{5}[3] Mohamed. Aitichou, Sharron.S.Saleh, Anita.K, McElroy, C. Schmaljohn, M.Sofi.Ibrahim. Identification of Dobrava, Hantaan, Seoul, and Puumala viruses by one-step real-time RT-PCR[J].Journal of Virological Methods. 2005, 124:21-26.}

{\\noindent\\zihao{5}[4] Wei Jiang, Hai-tao Yu, Ke Zhao, Ye Zhang, Hong Du, Ping-zhong Wang, Xue-fan Bai. Quantification of Hantaan Virus with a SYBR Green I-Based One-Step qRT-PCR Assay[J]. PLOS ONE. 2013. 8(11):1-9. }

\\end{document}
";

$content_r{'DX1762'}="
{\\noindent\\zihao{5}[1]  吕沐天,孙颖,刘沛,罗恩杰. 发热伴血小板减少综合征布尼亚病毒研究进展[J]. 微生物学杂志,2013,02:86-88.}

{\\noindent\\zihao{5}[2] 雷晓颖,张笑爽,于学杰. 发热伴血小板减少综合征布尼亚病毒研究进展[J]. 中国公共卫生,2014,07:967-971.}

{\\noindent\\zihao{5}[3] 王颖,邵柏,于长友,方绍庆,刘明杰,孙宝杰. 布尼亚病毒科概述[J]. 中国媒介生物学及控制杂志,2012,02:182-184.}

{\\noindent\\zihao{5}[4] 施超,喻荣彬,石平,陈善辉,谭文文,周建刚,钱燕华. 新型布尼亚病毒感染患者临床和血清流行病学特征分析[J]. 南京医科大学学报(自然科学版),2015,03:433-435. }

\\end{document}
";
$content_r{'DX1757'}="
{\\noindent\\zihao{5}[1] 王苏民。结核病及其实验室技术的现状与展望。中华检验医学杂志，2001，24(2)：71-72.}

{\\noindent\\zihao{5}[2] 陈效友，金玉生。Tag Man聚合酶链反应技术检测结核分枝杆菌DNA及临床应用。中华结核和呼吸杂志，2000，23(5)：283-288。}

{\\noindent\\zihao{5}[3] 韩纪勤。荧光定量聚合酶链反应诊断结核病临床应用研究。山西医科大学学报，2006.37(2)：180-181。}

{\\noindent\\zihao{5}[4] Kocagoz T，Ozkara S，Ozkara S．Detection of mycobacterium tuberculosis in sputum samples by polymerase chain reaction using a simplified procedure[J]. Chin Microbiology．1993．31(6)：1435。}

{\\noindent\\zihao{5}[5] 周步全，朱建峰，王迎春。结核分枝杆菌标本的不同处理方法对PCR扩增敏感性的影响。现代医学检验杂志，2005，20(6)：60-63。}

{\\noindent\\zihao{5}[6] 周辉，龚志平，钟白云。胸腹水脑脊液中结核杆菌的检测。实用预防医学，2005,12(1)：63-64。}

\\end{document}
";
$content_r{'DX1758'}="
{\\noindent\\zihao{5}[1]  Anjum M F , Zankari E , Hasman H . Molecular Methods for Detection of Antimicrobial Resistance[J]. Microbiology Spectrum, 2017, 5(6).}

{\\noindent\\zihao{5}[2] Mcdonald L C , Kuehnert M J , Tenover F C , et al. Vancomycin-resistant enterococci outside the health-care setting: prevalence, sources, and public health implications.[J]. Emerging Infectious Diseases, 1997, 3(3):311.}

{\\noindent\\zihao{5}[3] 李金明.实时荧光PCR技术.人民军医出版社，2007.}

{\\noindent\\zihao{5}[4] 喻浠明,李畅,张文慧,贾宇,张林波.细菌间bla\\_(NDM-1)传播规律的研究进展[J].生命科学,2018,30(11):1244-1251.}

{\\noindent\\zihao{5}[5] 张珍珍,吴俊伟,杨卫军.细菌耐药性产生的分子生物学机理及控制措施[J].动物医学进展,2008(02):106-109.}

{\\noindent\\zihao{5}[6] Murakami K , Minamide W , Wada K , et al. Identification of methicillin-resistant strains of staphylococci by polymerase chain reaction.[J]. Journal of Clinical Microbiology, 1991, 29(10):2240-2244.}

{\\noindent\\zihao{5}[7] 甘龙杰,陈善建,林宇岚,陈守涛,杨滨.碳青霉烯类耐药肠杆菌科细菌基因型检测及耐药性分析[J].临床检验杂志,2018,36(09):663-666.}

{\\noindent\\zihao{5}[8] Dallenne C , Costa A D , Dominique Decré, et al. Development of a set of multiplex PCR assays for the detection of genes encoding important beta-lactamases in Enterobacteriaceae.[J]. Journal of Antimicrobial Chemotherapy, 2010, 65(3):490.}

{\\noindent\\zihao{5}[9] Solanki R , Vanjari L , Subramanian S , et al. Comparative Evaluation of Multiplex PCR and Routine Laboratory Phenotypic Methods for Detection of Carbapenemases among Gram Negative Bacilli.[J]. J Clin Diagn Res, 2014, 8(12):23-6.}

{\\noindent\\zihao{5}[10] Poirel L , Walsh T R , Cuvillier V , et al. Multiplex PCR for detection of acquired carbapenemase genes[J]. Diagnostic Microbiology and Infectious Disease, 2011, 70(1):0-123.}

\\end{document}
";
$content_r{'DX1783'}="
{\\noindent\\zihao{5}[1]  儿童腺病毒肺炎诊疗规范(2019 年版).}

\\end{document}
";
$content_r{'DX1784'}="
{\\noindent\\zihao{5}[1] 雷永良, 陈秀英, 叶碧峰等. 实时荧光定量PCR 在登革热病毒快速检测中的应用[J]. 中国病原生物学杂志，2008,3（12）: 897-899.}

{\\noindent\\zihao{5}[2] 白志军，刘建伟，洪文艳等. TaqMan荧光定量PCR检测1型登革热病毒及临床应用[J]. 中国媒介生物学及控制杂志，2010,21（3）: 229-231-422.}

{\\noindent\\zihao{5}[3] 谢敏，王彤，谭秀莲，余涛，徐改凤. 登革热147例临床特点分析[J]. 岭南急诊医学杂志，2003，01:22-23.}

{\\noindent\\zihao{5}[4] 王佃鹏，朱玉兰，刘胜牙等. 登革热病毒多重荧光PCR 检测及基因分型方法的研究[J]. 热带医学杂志，2012, 12（8）: 936-939.}

{\\noindent\\zihao{5}[5] 中华医学会感染病学分会, 中华医学会热带病与寄生虫学分会, 中华中医药学会急诊分会, et al. 中国登革热临床诊断和治疗指南[J]. 传染病信息, 2018, 31(05):7-14.}


\\end{document}
";
$content_r{'DX1796'}="
{\\noindent\\zihao{5}[1] 卫海燕，许玉玲，马宏等.肠道病毒分子分型研究进展.中国病毒杂志，2012.2（1）：72-76.}

{\\noindent\\zihao{5}[2] Leitch EC, Harvala H, Robertson I, et al. Direct dentification of human enterovirus serotypes in cerebrospinal fluid by amplification and sequencing of the VP1 region[J].J Clin Virol, 2009, 44 (2)：119-124.}

{\\noindent\\zihao{5}[3] Hu YF, Yang F, Du J, et al. Complete genome analysis of coxsackie viurs A2, A4, A5, and A10 strains isolated from hand, foot, and mouth disease patients in China revealing frequent      recombination of human enterovirus A[J].J Clin Microbiol, 2011, 49 (7) :2426-2434.}

{\\noindent\\zihao{5}[4] 陈娜，马小珍，余倩等. 基于VP4区基因序列进行肠道病毒分型的可行性研究.预防医学情报杂志，2016（5）.}

\\end{document}
";

$content_r{'DX1867'}="

{\\noindent\\zihao{5}[1] Yamashita M, Krystal M, Fitch WM, Palese P. Influenza B virus evolution: co circulating lineages and comparison of evolutionary pattern with those of influenza A and C viruses. Virology[J]. 1988,163(1).112~122.}

{\\noindent\\zihao{5}[2] 舒跃龙等. 2004-2005年中国A（H1N1）亚型流感病毒抗原性及基因特性研究[J].临床医学, 2006,20(2):27~29.}

{\\noindent\\zihao{5}[3] 陈继明, 郭元吉. 乙型流行性感冒病毒两大谱系的起源及其演变特征[J]. 病毒学报, 2001,17(4):322~327.}

{\\noindent\\zihao{5}[4] 林立, 李昌崇. 呼吸道合胞病毒感染发病机制[J]. 中华儿科杂志 2006,44(9):673~675.}

{\\noindent\\zihao{5}[5] 高文娟, 金玉, 段招军. 人腺病毒的研究进展[J]. 病毒学报, 2014,30(2):193~200.}

{\\noindent\\zihao{5}[6] 王焕焕, 毛乃颖, 王善振等. 人鼻病毒的研究进展[J]. 病毒学报, 2011,27(3):294~297.}

{\\noindent\\zihao{5}[7] 陆权, 陆敏. 肺炎支原体感染的流行病学[J]. 实用儿科临床杂志, 2007,22(4):241~243.}

\\end{longtable}
\\end{document}
";

$content_r{'DX1868'}="

{\\noindent\\zihao{5}[1] Yamashita M, Krystal M, Fitch WM, Palese P. Influenza B virus evolution: co circulating lineages and comparison of evolutionary pattern with those of influenza A and C viruses. Virology[J]. 1988,163(1).112~122.}

{\\noindent\\zihao{5}[2] 舒跃龙等. 2004-2005年中国A（H1N1）亚型流感病毒抗原性及基因特性研究[J].临床医学, 2006,20(2):27~29.}

{\\noindent\\zihao{5}[3] 陈继明, 郭元吉. 乙型流行性感冒病毒两大谱系的起源及其演变特征[J]. 病毒学报, 2001,17(4):322~327.}

{\\noindent\\zihao{5}[4] 林立, 李昌崇. 呼吸道合胞病毒感染发病机制[J]. 中华儿科杂志 2006,44(9):673~675.}

{\\noindent\\zihao{5}[5] 高文娟, 金玉, 段招军. 人腺病毒的研究进展[J]. 病毒学报, 2014,30(2):193~200.}

{\\noindent\\zihao{5}[6] 王焕焕, 毛乃颖, 王善振等. 人鼻病毒的研究进展[J]. 病毒学报, 2011,27(3):294~297.}

{\\noindent\\zihao{5}[7] 陆权, 陆敏. 肺炎支原体感染的流行病学[J]. 实用儿科临床杂志, 2007,22(4):241~243.}

{\\noindent\\zihao{5}[8] Lu R, Zhao X, Li J et al.. Genomic characterisation and epidemiology of 2019 novel coronavirus: implications for virus origins and receptor binding. Lancet. 2020 Feb 22;395(10224):565-574.}

{\\noindent\\zihao{5}[9] Zhu N, Zhang D, Wang W, et al.. A Novel Coronavirus from Patients with Pneumonia in China, 2019. N Engl J Med. 2020 Feb 20;382(8):727-733.}

{\\noindent\\zihao{5}[10] Xie C, Jiang L, Huang G, et al.. Comparison of different samples for 2019 novel coronavirus detection by nucleic acid amplification tests. Int J Infect Dis. 2020 Feb 27;93:264-267.}

{\\noindent\\zihao{5}[11] Ling Y, Xu SB, Lin YX, et al.. Persistence and clearance of viral RNA in 2019 novel coronavirus disease rehabilitation patients. Chin Med J (Engl). 2020 Feb 28. doi: 10.1097/CM9.0000000000000774. [Epub ahead of print]}

\\end{longtable}
\\end{document}
";

$content_r{'SD0221'}="

{\\noindent\\zihao{5}[1] 暂无}

\\end{document}
";
	if ($hospital =~ /千麦/){
		print OUT encode("utf8",decode("gbk",$content_QM));
	}
	else{
		print OUT encode("utf8",decode("gbk",$content_1));
		print OUT encode("utf8",decode("gbk",$content_s{${version}}));
		print OUT encode("utf8",decode("gbk",$content_r{${version}}));
	}
}

{
	$| = 1; my $i = 10; while($i){ print "自动提取已完成，请关闭程序($i秒后自动关闭)\r"; $i--; sleep(1); }
}

#============================sub routine=====================
