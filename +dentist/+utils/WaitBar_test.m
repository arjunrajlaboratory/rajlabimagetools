dentist.tests.cleanupForTests;

x = dentist.utils.WaitBar('WaitBar Test');
x.showProgress(1, 5)
x.showProgress(2, 5)
x.showProgress(3, 5)
x.showProgress(4, 5)
x.showProgress(5, 5)
delete(x);

x = dentist.utils.WaitBar('WaitBar Test', 'number');
x.showProgress(1, 5, 1, 2)
x.showProgress(2, 5, 1, 2)
x.showProgress(3, 5, 1, 2)
x.showProgress(4, 5, 1, 2)
x.showProgress(5, 5, 1, 2)
x.showProgress(1, 5, 2, 2)
x.showProgress(2, 5, 2, 2)
x.showProgress(3, 5, 2, 2)
x.showProgress(4, 5, 2, 2)
x.showProgress(5, 5, 2, 2)
delete(x);
