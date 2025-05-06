function notify(Status,email,message)
arguments
    Status string {mustBeMember(Status,{'Complete','Error','Info'})}
    email string
    message string = "";
end
switch Status
    case 'Complete'
        dcrg.sendEmail(email,'MATLAB: JOB Complete',message);
    case 'Error'
        dcrg.sendEmail(email,'MATLAB: JOB Error',message);
    case 'Info'
        dcrg.sendEmail(email,'MATLAB: JOB Information',message);
end
end

