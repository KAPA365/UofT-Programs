import { Component, OnInit } from '@angular/core';
import { NgForm } from '@angular/forms';
import { Router } from '@angular/router';
import { UserService } from '../services/user.service';

@Component({
  selector: 'app-register',
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.css']
})
export class RegisterComponent implements OnInit {
  constructor(
    private userService: UserService,
    private router: Router,
  ) { }

  ngOnInit(): void { }

  onFormSubmit(form: NgForm) {
    const name = form.value.name;
    const email = form.value.email;
    const color = form.value.color; // color from form

    this.userService.postRegister(name, email, color).subscribe((response: any) => { // added color
      // Once we've received a response, take the user to the home page
      this.router.navigate(['/home'], { // removed byurl and added params
        queryParams: {
          name: name,
          userId: response.user_id,
          color: color
        }
      });
    })
  }
}
