if config["fastq"].get("pe"):
    rule fastp_pe:
        input:
            sample=get_fastq
        output:
            trimmed=[temp("results/trimmed/{s}{u}_1.fastq.gz"), temp("results/trimmed/{s}{u}_2.fastq.gz")],
            html=temp("report/{s}{u}.fastp.html"),
            json=temp("report/{s}{u}.fastp.json"),
        log:
            "logs/trim/{s}{u}.log"
        threads: 32
        wrapper:
            config["warpper_mirror"]+"bio/fastp"
else:
    rule fastp_se:
        input:
            sample=get_fastq
        output:
            trimmed=temp("results/trimmed/{s}{u}.fastq.gz"),
            html=temp("report/{s}{u}.fastp.html"),
            json=temp("report/{s}{u}.fastp.json"),
        log:
            "logs/trim/{s}{u}.log"
        threads: 32
        wrapper:
            config["warpper_mirror"]+"bio/fastp"
