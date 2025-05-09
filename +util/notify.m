function notify(Status,message,email)
arguments
    Status string {mustBeMember(Status,{'Complete','Error','Info'})}
    message string = "";
    email string = "";
end
switch Status
    case 'Complete'
        dcrg.sendEmail('MATLAB: JOB Complete',message,email);
    case 'Error'
        dcrg.sendEmail('MATLAB: JOB Error',message,email);
    case 'Info'
        dcrg.sendEmail('MATLAB: JOB Information',message,email);
end
end

